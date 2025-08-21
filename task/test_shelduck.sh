
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../hoid.sh


test_run() {

	# shellcheck disable=SC2016
	hoid shelduck run --output var:test_run_output 'val:


''shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh''
x=xyz
x=$(bobshell_replace "$x" x 1)
x=$(bobshell_replace "$x" y 2)
x=$(bobshell_replace "$x" z 3)
printf %s "$x"
'

	assert_equals 123 "$test_run_output"
}


