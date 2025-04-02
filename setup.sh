


hoid_setup_done=false

hoid_setup_ensure() {
	if [ true = "${hoid_setup_done:-false}" ]; then
		return
	fi
	bobshell_stack_set hoid_state_stack
	bobshell_event_fire hoid_setup_event
	hoid_setup_done=true
}