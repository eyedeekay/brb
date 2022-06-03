#! /usr/bin/env bash
cd "$(dirname "$0")"
make daily
make upload-windows