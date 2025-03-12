
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh


init_dir() {
	set -- "target/$1"
	rm -rf "$1"
	mkdir -p "$1"
	cd "$1"
}

test_copy_one_plain() {
	init_dir test_copy_one_plain
	ssh "$HOID_TARGET" rm -f test_copy_one_plain.txt
	echo 'hello' > file.txt
	test_copy_name=somename
	hoid copy file:file.txt test_copy_one_plain.txt
	assert_equals 'hello' "$(ssh "$HOID_TARGET" cat test_copy_one_plain.txt)" 
}

test_copy_one_template() {
	init_dir test_copy_one_template
	ssh "$HOID_TARGET" rm -f test_copy_one_template.txt
	echo 'hello, {{ test_copy_name }}' > file.txt
	test_copy_name=somename
	hoid copy --mustache  file:file.txt test_copy_one_template.txt
	assert_equals 'hello, somename' "$(ssh "$HOID_TARGET" cat test_copy_one_template.txt)" 
}

test_copy_multi_plain() {
	init_dir test_copy_multi_plain
	ssh "$HOID_TARGET" 'rm -rf test_copy_multi_plain'
	mkdir -p dir
	echo 'hello' > dir/hello.txt
	echo 'hi'    > dir/hi.txt
	test_copy_name=somename
	hoid copy file:dir test_copy_multi_plain
	assert_equals 'hello' "$(ssh "$HOID_TARGET" 'cat test_copy_multi_plain/hello.txt')"
	assert_equals 'hi' "$(ssh "$HOID_TARGET" 'cat test_copy_multi_plain/hi.txt')"
}

test_copy_multi_template() {
	init_dir test_copy_multi_template
	ssh "$HOID_TARGET" 'rm -rf test_copy_multi_template'
	mkdir -p dir
	echo 'hello, {{ test_copy_name }}' > dir/hello.txt
	echo 'hi, {{ test_copy_name }}'    > dir/hi.txt
	test_copy_name=somename
	hoid copy --mustache  file:dir test_copy_multi_template
	assert_equals 'hello, somename' "$(ssh "$HOID_TARGET" 'cat test_copy_multi_template/hello.txt')"
	assert_equals 'hi, somename' "$(ssh "$HOID_TARGET" 'cat test_copy_multi_template/hi.txt')"
}


test_copy_first_file() {
	init_dir test_copy_first_file
	mkdir -p "dir1/$HOID_TARGET" "dir2/$HOID_TARGET" "dir3/$HOID_TARGET"

	HOID_FINDER_PATH='dir1/{{ hoid_profile }}:dir2/{{ hoid_profile }}:dir3/{{ hoid_profile }}'
	#bobshell_event_var_set hoid_profile testprof

	echo hello > "dir1/$HOID_TARGET/file.txt"
	echo hi    > "dir3/$HOID_TARGET/file.txt"

	hoid copy file.txt test_copy_first_file.txt
	assert_equals hello "$(ssh "$HOID_TARGET" 'cat test_copy_first_file.txt')"
}

