



shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../../util.sh
shelduck import ./pyenv.sh
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh


test_pyenv() {
	hoid_testcontainer_run do_test_pyenv
}

do_test_pyenv() {
	hoid install pyenv
}

