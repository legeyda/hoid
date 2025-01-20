
hoid_driver_local_init() {
	true # do nothing here
}

hoid_driver_local_shell() {
	bobshell_log "$1"
	sh -c "$1"
}


