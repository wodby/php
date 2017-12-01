{{ range jsonArray (getenv "SSH_PUBLIC_KEYS") }}{{ . }}
{{ end }}