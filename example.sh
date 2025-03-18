#!/usr/bin/env shelduck_run
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh

HOID_SCRIPT=narrowboat

hoid find-all narrowboat/env.sh \
		bobshell_eval

hoid --become true --become-password 123 --target ubuntu24server --name 'example hoid script' block start
hoid -n 'create working directory' directory ./target/hello
hoid -n 'print greeting' command echo hello
