
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../../util.sh
shelduck import ./proot.sh
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh


test_install_proot() {
	hoid_testcontainer_run do_test_install_proot
}

do_test_install_proot() {
	hoid install proot
	hoid command --output var:_do_test_install_proot__output proot --version
	assert_contains "$_do_test_install_proot__output" Copyright
	unset _do_test_install_proot__output
}
