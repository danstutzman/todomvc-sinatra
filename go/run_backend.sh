#!/bin/bash -ex
go run backend.go handlers.go \
  -postgres_credentials_path postgres_credentials.dev.json \
  "$@"
