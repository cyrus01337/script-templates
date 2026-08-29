#!/usr/bin/env bash
set -e

argon sourcemap --non-scripts --output sourcemap.json
wally-package-types --sourcemap sourcemap.json
