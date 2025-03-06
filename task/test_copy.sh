
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh

test_copy() {
	ssh "$HOID_TARGET" 'rm -f test_copy.txt'
	rm -rf target/test_copy
	mkdir -p target/test_copy
	echo 'hello, {{ test_copy_name }}' > target/test_copy/file.txt
	test_copy_name=somename
	hoid copy --mustache  file://target/test_copy/file.txt test_copy.txt
	assert_equals 'hello, somename' "$(ssh "$HOID_TARGET" 'cat test_copy.txt')" 
}
