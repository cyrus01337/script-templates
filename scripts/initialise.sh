#!/usr/bin/env bash
set -e

if ! command -v rokit &> /dev/null; then
    printf "rokit binary missing, please install rokit:\n\n"
    echo "https://github.com/rojo-rbx/rokit#installation"

    exit 1
fi

rokit install
wally install
argon sourcemap --non-scripts --output sourcemap.json
wally-package-types --sourcemap sourcemap.json
