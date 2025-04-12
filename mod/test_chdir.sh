
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh

test_chdir() {
	unset root
	hoid script --output var:root 'printf %s $(pwd)'
	assert_isset root

	unset x
	hoid --chdir 1 script --output var:x 'printf %s $(pwd)'
	assert_isset x
	assert_equals "$x" "$root/1"

	hoid --chdir 2 init
	unset x
	hoid script --output var:x 'printf %s $(pwd)'
	assert_isset x
	assert_equals "$x" "$root/1/2"

	hoid --chdir 3 block start
	unset x
	hoid script --output var:x 'printf %s $(pwd)'
	assert_isset x
	assert_equals "$x" "$root/1/2/3"

	hoid block end
	unset x
	hoid script --output var:x 'printf %s $(pwd)'
	assert_isset x
	assert_equals "$x" "$root/1/2"

	hoid --chdir .. init
	unset x
	hoid script --output var:x 'printf %s $(pwd)'
	assert_isset x
	assert_equals "$x" "$root/1"

	hoid --chdir /. init
	unset x
	hoid script --output var:x 'printf %s $(pwd)'
	assert_isset x
	assert_equals "$x" "/"

}
