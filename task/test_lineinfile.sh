
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../util.sh
shelduck import ./lineinfile.sh
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh


test_no_file() {
	assert_die do_test_with_hoid lineinfile hello ./msg.txt
}

do_test_with_hoid() {
	mkcd
	hoid --driver local block start
	hoid "$@"
	hoid buffer flush
	hoid block end
}


test_lineinfile() {
	mkcd
	hoid --driver local block start
	
	hoid command touch -a ./msg.txt
	hoid lineinfile hello ./msg.txt
	hoid buffer flush
	assert_file_exists ./msg.txt
	assert_file_contents hello ./msg.txt

	hoid lineinfile hello ./msg.txt
	hoid buffer flush
	assert_file_exists ./msg.txt
	assert_file_contents hello ./msg.txt
	

	hoid lineinfile there ./msg.txt
	hoid buffer flush
	assert_file_exists ./msg.txt
	assert_file_contents "hello${bobshell_newline}there" ./msg.txt
	
}