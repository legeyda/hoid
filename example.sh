#!/usr/bin/env shelduck_run
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh

hoid init "$@"
hoid directory ./target/hello
hoid command echo hello
