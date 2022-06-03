#! /usr/bin/env bash
cd "$(dirname "$0")"
git pull --all
CGO_ENABLED=0 GOOS=windows go build -a -tags "netgo osusergo windows" -ldflags '-H=windowsgui' -o brb-windows.exe
make daily
sleep 2s
make upload-windows-daily