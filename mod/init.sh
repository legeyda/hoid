
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/result/set.sh


# fun: hoid_sub_init 
hoid_sub_init() {
	hoid_buffer_flush
	hoid_state_init "$@"
	bobshell_event_fire hoid_state_change_event
}


hoid_setup_done=false


bobshell_sub_init_subcommand_event_listener() {
	if [ true != "${hoid_setup_done:-false}" ]; then
		bobshell_stack_set hoid_state_stack
	fi

	if [ init = "$1" ]; then
		shift
		hoid_sub_init "$@"
		hoid_setup_done=true
		bobshell_result_set true
		return
	fi

	bobshell_result_set false
}

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_subcommand '
	bobshell_sub_init_subcommand_event_listener "$@"
	if bobshell_result_check; then
		return
	fi
'



