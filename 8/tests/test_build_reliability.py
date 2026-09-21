"""Exercise download retries, secret handling and failed service startup locally."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BuildReliability(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.env = {**os.environ, 'PATH': f'{self.work}:{os.environ["PATH"]}',
                    'TEST_WORK': str(self.work)}
        self.env.pop('COMPOSER_AUTH', None)
        self.env.pop('PIE_COMPOSER_AUTH_FILE', None)
        self.command('sleep', 'exit 0')

    def command(self, name, body):
        path = self.work / name
        path.write_text('#!/usr/bin/env bash\nset -eu\n' + body + '\n')
        path.chmod(0o755)

    def pie(self, message='', failures=0, authenticated=False):
        self.env.update(TEST_FAILURE=message, TEST_FAILURES=str(failures))
        # This is a deliberately fake value; assert it never appears in output.
        secret = '{"github-oauth":{"github.com":"test-secret-never-log"}}'
        if authenticated:
            auth = self.work / 'auth'
            auth.write_text(secret)
            self.env['PIE_COMPOSER_AUTH_FILE'] = str(auth)
        else:
            self.env['PIE_COMPOSER_AUTH_FILE'] = str(self.work / 'absent')
        self.env['TEST_AUTHENTICATED'] = str(int(authenticated))
        self.command('pie', '''
count=0
[[ ! -f "$TEST_WORK/count" ]] || count=$(cat "$TEST_WORK/count")
count=$((count + 1))
echo "$count" > "$TEST_WORK/count"
if [[ "$TEST_AUTHENTICATED" == 1 ]]; then
    [[ "$COMPOSER_AUTH" == '{"github-oauth":{"github.com":"test-secret-never-log"}}' ]]
else
    [[ -z "${COMPOSER_AUTH:-}" ]]
fi
if (( count <= TEST_FAILURES )); then
    echo "$TEST_FAILURE" >&2
    exit 17
fi
''')
        result = subprocess.run(['bash', '-c', '''
set -euo pipefail
build_dir=$TEST_WORK
jobs=2
source "$1/pie-install.sh"
set -x
install_pie example/extension:1.2.3
[[ -z "${COMPOSER_AUTH:-}" ]]
''', 'test', str(ROOT)], env=self.env, capture_output=True, text=True)
        self.assertNotIn('test-secret-never-log', result.stdout + result.stderr)
        return result, int((self.work / 'count').read_text())

    def test_secret_is_available_only_to_pie_even_with_tracing(self):
        result, attempts = self.pie(authenticated=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(attempts, 1)

    def test_anonymous_local_build_is_supported(self):
        result, attempts = self.pie()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(attempts, 1)

    def test_transient_download_failures_are_retried(self):
        for error in ('curl error 28 while downloading', 'HTTP/2 429', 'HTTP/1.1 503',
                      'API rate limit exceeded', 'Connection reset by peer'):
            with self.subTest(error=error):
                (self.work / 'count').unlink(missing_ok=True)
                result, attempts = self.pie(error, failures=1)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(attempts, 2)

    def test_retries_stop_after_three_attempts(self):
        result, attempts = self.pie('HTTP/2 502', failures=10)
        self.assertEqual(result.returncode, 17)
        self.assertEqual(attempts, 3)

    def test_permanent_failures_are_not_retried(self):
        for error in ('Could not authenticate against github.com', 'HTTP/2 401',
                      'configure: error: missing dependency', 'fatal error: compilation failed'):
            with self.subTest(error=error):
                (self.work / 'count').unlink(missing_ok=True)
                result, attempts = self.pie(error, failures=10)
                self.assertEqual(result.returncode, 17)
                self.assertEqual(attempts, 1)

    def test_all_build_targets_pass_secret_by_environment_name(self):
        for target in ('build', 'build-debug', 'buildx-build', 'buildx-push'):
            with self.subTest(target=target):
                result = subprocess.run(['make', '-n', target], cwd=ROOT,
                                        env={**self.env, 'COMPOSER_AUTH': 'test-secret-never-log'},
                                        capture_output=True, text=True, check=True)
                self.assertIn('--secret id=composer_auth,env=COMPOSER_AUTH', result.stdout)
                self.assertNotIn('test-secret-never-log', result.stdout + result.stderr)
                anonymous = subprocess.run(['make', '-n', target], cwd=ROOT, env=self.env,
                                           capture_output=True, text=True, check=True)
                self.assertNotIn('--secret', anonymous.stdout)

    def run_services(self, arch, fail_start):
        self.env.update(IMAGE='test/php', DEBUG='', TEST_ARCH=arch,
                        TEST_FAIL_START=str(int(fail_start)))
        self.command('docker', '''
printf '%s\\n' "$*" >> "$TEST_WORK/docker.log"
if [[ "$*" == 'run --rm --entrypoint uname test/php -m' ]]; then
    echo "$TEST_ARCH"
elif [[ "$*" == *' up -d '* && "$TEST_FAIL_START" == 1 ]]; then
    exit 42
elif [[ "$*" == *'ps --all --quiet sqlserver' ]]; then
    echo sqlserver-id
elif [[ "$*" == 'compose exec -T php bash /usr/local/bin/functional/run.sh' ]]; then
    exit 43
fi
''')
        result = subprocess.run(['bash', str(ROOT / 'tests/run.sh')], cwd=ROOT / 'tests',
                                env=self.env, capture_output=True, text=True)
        log = (self.work / 'docker.log').read_text()
        self.assertIn('compose --profile sqlserver ps --all', log)
        self.assertIn('inspect --format {{json .State}} sqlserver-id', log)
        self.assertIn('compose --profile sqlserver logs --tail=100', log)
        self.assertIn('compose --profile sqlserver down -v --remove-orphans', log)
        return result, log

    def test_unhealthy_sqlserver_stops_tests_and_preserves_failure(self):
        result, log = self.run_services('x86_64', True)
        self.assertEqual(result.returncode, 42)
        self.assertIn('compose --profile sqlserver up -d --wait --wait-timeout 180', log)
        self.assertNotIn('compose exec', log)

    def test_arm64_does_not_start_sqlserver_and_keeps_test_failures(self):
        result, log = self.run_services('aarch64', False)
        self.assertEqual(result.returncode, 43)
        self.assertIn('compose up -d --wait --wait-timeout 180', log)
        self.assertNotIn('compose --profile sqlserver up', log)


if __name__ == '__main__':
    unittest.main()
