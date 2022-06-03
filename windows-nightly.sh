#! /usr/bin/env bash
cd "$(dirname "$0")"
git pull --all
CGO_ENABLED=0 GOOS=windows go build $(WIN_GO_COMPILER_OPTS) -o $(packagename)-windows.exe
make daily
sleep 2s
make upload-windows-daily