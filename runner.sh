#!/usr/bin/env shelduck_run
set -eu

shelduck import hoid.sh

main() {
	hoid "$@"
}

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/entry_point.sh