
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../hoid.sh


init_dir() {
	set -- "target/$1"
	rm -rf "$1"
	mkdir -p "$1"
	cd "$1"
}

test_install_1() {
	init_dir test_git_install
	ssh "$HOID_TARGET" rm -rf hoid-tailsitter
	hoid git clone https://github.com/legeyda/tailsitter.git hoid-tailsitter
	ssh "$HOID_TARGET" 'cat hoid-tailsitter/README.md'
}

test_install_2() {
	init_dir test_git_install
	ssh "$HOID_TARGET" rm -rf hoid-tailsitter
	hoid --chdir hoid-tailsitter git clone https://github.com/legeyda/tailsitter.git
	ssh "$HOID_TARGET" 'cat hoid-tailsitter/tailsitter/README.md'
}
