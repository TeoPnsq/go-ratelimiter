#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

go_bin="$(go env GOPATH)/bin"
if ! command -v golangci-lint >/dev/null 2>&1; then
  if [ -x "$go_bin/golangci-lint" ]; then
    PATH="$go_bin:$PATH"
    export PATH
  else
    echo "golangci-lint is not on PATH. Install it: go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest" >&2
    exit 1
  fi
fi

echo "==> go vet"
go vet ./...

echo "==> golangci-lint"
golangci-lint run ./...

echo "==> go test"
go test -race -shuffle=on ./...

echo "All checks passed."
