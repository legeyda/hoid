


# fun: hoid_sub_init 
hoid_sub_init() {
	if [ true != "${_hoid__state_default_done:-false}" ]; then
		bobshell_stack_set hoid_state_stack
		_hoid__state_default_done=true
	fi
	hoid_buffer_flush
	hoid_state_init "$@"
}

hoid_sub_init_ensure() {
	if [ true != "${_hoid__state_default_done:-false}" ]; then
		bobshell_stack_set hoid_state_stack
		bobshell_event_fire hoid_event_state_default
		_hoid__state_default_done=true
	fi
}

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_subcommand '


	if [ init = "$1" ]; then
		shift
		hoid_sub_init "$@"
		return
	else
		hoid_sub_init_ensure
	fi

	if ! bobshell_isset hoid_target; then
		bobshell_die "hoid target not set"
	fi
'



