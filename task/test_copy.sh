
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh


init_dir() {
	set -- "target/$1"
	rm -rf "$1"
	mkdir -p "$1"
	cd "$1"
}

test_copy_one() {
	init_dir test_copy_one
	ssh "$HOID_TARGET" rm -f test_copy_one.txt
	echo 'hello, {{ test_copy_name }}' > file.txt
	test_copy_name=somename
	hoid copy --mustache  file:file.txt test_copy_one.txt
	assert_equals 'hello, somename' "$(ssh "$HOID_TARGET" cat test_copy_one.txt)" 
}

test_copy_multi() {
	init_dir test_copy_multi
	ssh "$HOID_TARGET" 'rm -rf test_copy_multi'
	mkdir -p dir
	echo 'hello, {{ test_copy_name }}' > dir/hello.txt
	echo 'hi, {{ test_copy_name }}'    > dir/hi.txt
	test_copy_name=somename
	hoid copy --mustache  dir test_copy_multi
	assert_equals 'hello, somename' "$(ssh "$HOID_TARGET" 'cat test_copy_multi/hello.txt')" 
	assert_equals 'hi, somename' "$(ssh "$HOID_TARGET" 'cat test_copy_multi/hi.txt')" 
}
