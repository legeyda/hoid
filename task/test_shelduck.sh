
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh


test_run() {

	# shellcheck disable=SC2016
	hoid shelduck run 'val:


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
x=xyz
x=$(bobshell_replace "$x" x 1)
x=$(bobshell_replace "$x" y 2)
x=$(bobshell_replace "$x" z 3)
printf %s "$x"
'

}


