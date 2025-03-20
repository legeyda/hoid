
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh


init_dir() {
	set -- "target/$1"
	rm -rf "$1"
	mkdir -p "$1"
	cd "$1"
}

test_become() {
	init_dir test_become

	unset x
	hoid --become true    script --output var:x    id -u
	assert_equals 0 "$x"
}
