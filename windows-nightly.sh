#! /usr/bin/env bash
. "$HOME/github-release-config.sh"
cd "$(dirname "$0")"
export DAILY="$(date +%Y%m%d)"
git pull --all
CGO_ENABLED=0 GOOS=windows go build -a -tags "netgo osusergo windows" -ldflags '-H=windowsgui' -o brb-windows.exe
make daily
sleep 2s
make upload-windows-daily