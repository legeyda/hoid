
shelduck import ../../hoid.sh
shelduck import ../../util.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh

test_remove() {
	hoid_testcontainer_run do_test_remove
}

do_test_remove() {
	hoid command apt-get install --yes nginx
	hoid package remove nginx
	hoid script --output var:out 'nginx -t || echo blablasuccess'
	assert_contains "$out" blablasuccess
}