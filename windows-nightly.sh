#! /usr/bin/env bash
cd "$(dirname "$0")"
git pull --all
make windows-runner
make daily
sleep 2s
make upload-windows-daily