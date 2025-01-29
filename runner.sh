#!/usr/bin/env shelduck_run
set -eu

shelduck import hoid.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh

main() {
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-t|--target)
				hoid init "$2"
				shift 2
		esac
	done

	hoid init "$@"
	bobshell_eval "file:$1"
}

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/entry_point.sh