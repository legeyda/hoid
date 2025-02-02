#!/usr/bin/env shelduck_run
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh

hoid --become true --target ubuntu24server --name 'example hoid script' block start
hoid -n 'create working directory' directory ./target/hello
hoid -n 'print greeting' command echo hello
