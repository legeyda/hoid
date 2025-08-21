
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../hoid.sh


# fun: run_sshd PASSWORD
run_test_container() {
	docker stop hoid_test || true
	docker run --detach --name hoid_test --rm ubuntu sleep 99
	bobshell_event_listen bobshell_exit_event 'docker stop hoid_test || true'
	docker exec hoid_test echo started
}

todo_test_shelduck() {
	run_test_container
	hoid --driver docker --target hoid_test init
	hoid install shelduck
	hoid buffer flush
	hoid script --output var:_test_shelduck__out '. /etc/profile; shelduck run "val:echo hello"'
	
	#assert_equals hello "$_test_shelduck__out"
	
}