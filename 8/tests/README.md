# PHP image tests

From `8/`, run `make test REPO=wodby/php TAG=8.5` against an already-built image.
Set `COMPOSE_PROJECT_NAME` to a unique value when running suites concurrently.
The same suite runs in CI for PHP 8.2–8.5, both architectures, and production,
development, and development macOS UID variants.

The suite retains module/version/build-option checks and adds functional smoke
tests for every extension formerly installed through PECL:

| Extensions | Functional check |
| --- | --- |
| apcu | Store, fetch, and delete cached structured data |
| ast, ds | Parse an assignment/expression; manipulate a map |
| event | Deliver data through a buffer pair and execute its event callback |
| grpc | Exchange a request, response, and status over a local HTTP/2 connection |
| igbinary, protobuf, yaml, uuid | Encode/decode round trips; UUID generation and validation |
| imagick | Create, resize, encode, and decode a PNG; verify dimensions and a pixel |
| imap, oauth | Read a local mailbox and parse MIME/addresses; verify OAuth normalization and an HMAC-SHA1 signature |
| opentelemetry, xhprof | Invoke registered hooks; collect actual profiling data |
| pcov, xdebug | Record an executed fixture line in separate coverage processes |
| uploadprogress | Observe progress during a partial multipart upload to PHP-FPM and verify the completed file hash |
| redis, memcached | Write, read, and delete data through real servers |
| amqp | Publish, receive, and acknowledge a RabbitMQ message |
| mongodb | Insert, query, and delete a document through the native driver |
| rdkafka | Produce a Kafka message, confirm delivery, and consume its payload/key |
| smbclient | Authenticate and write, read, and delete a file on a Samba share |
| sqlsrv, pdo_sqlsrv | Create temporary tables, execute parameterized inserts, and fetch rows from SQL Server |

SQL Server integration runs only on **amd64**. Microsoft's Linux server container
[requires x86-64](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker).
On arm64 the suite prints an explicit skip for these two integrations; their
module/version checks still run. It does not emulate SQL Server or silently count
an unavailable service as passing.

These are representative functional checks, not exhaustive upstream test suites.
IMAP and OAuth exercise local processing; they do not test an external mail server
or OAuth provider. TLS interoperability and every optional serializer are not
covered by the round trips; existing build-feature checks remain in place.

Service containers use an isolated Compose network without host port mappings.
Their credentials are test fixtures only. The runner removes containers and
anonymous volumes on both success and failure, and prints service logs on failure.
Service readiness retries are bounded. Coverage engines run separately, and the
upload fixture talks FastCGI directly to avoid nginx buffering the request before
PHP can observe progress.
