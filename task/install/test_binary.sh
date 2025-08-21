

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../../util.sh
shelduck import ./binary.sh
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh


test_install_binary() {
	hoid_testcontainer_run do_test_install_binary
}

do_test_install_binary() {
	hoid install binary stdin: testbinary <<EOF
#!/bin/sh
printf %s 'hello from testbinary'
EOF

	hoid script --output var:_do_test_install_binary__output 'testbinary'
	assert_equals 'hello from testbinary' "$_do_test_install_binary__output"
	unset _do_test_install_binary__output
}





