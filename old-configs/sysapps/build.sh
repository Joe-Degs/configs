#!/usr/bin/env bash

apps=(screenshot superbackup)
bin=./bin
GO_COMMAND="go build"
CGO_ENABLED=1

build() {
    [ -n "$1" ] && $GO_COMMAND -o ${bin}/$1 cmd/$1/main.go && exit 0
    for app in "${apps[@]}"; do
        ${GO_COMMAND} -o ${bin}/${app} cmd/${app}/main.go
    done
}

build
