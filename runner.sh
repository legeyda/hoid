#!/usr/bin/env shelduck_run
set -eu

shelduck import hoid.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh

main() {
	bobshell_eval "file:$1"
}

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/entry_point.sh