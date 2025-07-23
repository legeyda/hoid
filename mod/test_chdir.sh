
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh
shelduck import ../util.sh

test_chdir() {
	hoid_testcontainer_run do_test_chdir
}

do_test_chdir() {
	print_pwd='printf %s $(pwd)'

	unset root
	hoid script --output var:root "$print_pwd"
	assert_isset root

	unset x
	hoid script --output var:x "$print_pwd"
	assert_isset x
	assert_equals "$root" "$x"

	if [ / = "$root" ]; then
		root=
	fi

	reset
	unset x
	hoid --chdir 1 script --output var:x "$print_pwd"
	assert_isset x
	assert_equals "$root/1" "$x"

	unset x
	hoid script --output var:x "$print_pwd"
	assert_isset x
	assert_equals "$root" "$x"

	hoid --chdir 1/2 init
	unset x
	hoid script --output var:x "$print_pwd"
	assert_isset x
	assert_equals "$root/1/2" "$x"

	hoid --chdir 3 block start
	unset x
	hoid script --output var:x "$print_pwd"
	assert_isset x
	assert_equals "$root/1/2/3" "$x"

	hoid block end
	unset x
	hoid script --output var:x "$print_pwd"
	assert_isset x
	assert_equals "$root/1/2" "$x"

	hoid --chdir .. init
	unset x
	hoid script --output var:x "$print_pwd"
	assert_isset x
	assert_equals "$root/1" "$x"

	hoid --chdir /. init
	unset x
	hoid script --output var:x "$print_pwd"
	assert_isset x
	assert_equals / "$x"

}
