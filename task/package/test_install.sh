
shelduck import ../../hoid.sh
shelduck import ../../util.sh

test_install() {
	hoid_testcontainer_run do_test_install
}

do_test_install() {
	hoid package install nginx
	hoid command nginx -t
}