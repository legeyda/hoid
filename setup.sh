
shelduck import ./state.sh

hoid_setup_done=false

hoid_setup_ensure() {
	if [ true = "${hoid_setup_done:-false}" ]; then
		return
	fi
	hoid_setup_done=true
	bobshell_event_fire hoid_setup_event
}

bobshell_event_listen hoid_setup_event hoid_setup_event_listener
hoid_setup_event_listener() {
	bobshell_stack_set hoid_state_stack
	hoid_state_init
}