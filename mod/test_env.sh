
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../hoid.sh

test_env() {

	test_env_script='val:shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
if bobshell_isset TVAR1; then
	printf "TVAR1 is %s" "$TVAR1 is set"
else
	printf "TVAR1 is NOT set"
fi
if bobshell_isset TVAR2; then
	printf "TVAR2 is %s" "$TVAR2 is set"
else
	printf "TVAR2 is NOT set"
fi
if bobshell_isset TVAR3; then
	printf "TVAR3 is %s" "$TVAR3 is set"
else
	printf "TVAR3 is NOT set"
fi

'

	unset tout
	HOID_ENV=TVAR1=xxx
	hoid shelduck run --output var:tout "$test_env_script"
	assert_ok bobshell_contains "$tout" 'TVAR1 is xxx'
	assert_ok bobshell_contains "$tout" 'TVAR2 is NOT set'
	assert_ok bobshell_contains "$tout" 'TVAR3 is NOT set'

	unset tout
	hoid --env TVAR2=yyy init
	hoid shelduck run --output var:tout "$test_env_script"
	assert_ok bobshell_contains "$tout" 'TVAR1 is xxx'
	assert_ok bobshell_contains "$tout" 'TVAR2 is yyy'
	assert_ok bobshell_contains "$tout" 'TVAR3 is NOT set'
	

	unset tout
	hoid --env TVAR3=zzz  block start 
	hoid  init
	hoid shelduck run --output var:tout "$test_env_script"
	assert_ok bobshell_contains "$tout" 'TVAR1 is xxx'
	assert_ok bobshell_contains "$tout" 'TVAR2 is yyy'
	assert_ok bobshell_contains "$tout" 'TVAR3 is zzz'
	hoid block end

	unset tout
	hoid shelduck run --output var:tout "$test_env_script"
	assert_ok bobshell_contains "$tout" 'TVAR1 is xxx'
	assert_ok bobshell_contains "$tout" 'TVAR2 is yyy'
	assert_ok bobshell_contains "$tout" 'TVAR3 is NOT set'
	



}
