#!/bin/sh

set -eu

export TZ=JST-9

./configure
make check
