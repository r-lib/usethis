#!/usr/bin/env bash

set -e

shopt -s extglob
clang-format -i src/!(RcppExports).@(c|h|cpp) && git diff-files -U --exit-code
