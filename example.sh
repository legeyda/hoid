#!/usr/bin/env shelduck_run
set -eu


shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh


main() {
	HOID_TARGET=ssh:admin@ubuntu24server
	hoid init
	hoid directory ./target/hello
	hoid shell 'echo hello all'
}



shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/entry_point.sh