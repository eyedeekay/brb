#! /usr/bin/env bash
cd "$(dirname "$0")"
make plugins
make daily
sleep 2s
make upload-windows-daily