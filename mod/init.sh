
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/result/set.sh


# fun: hoid_sub_init 
hoid_sub_init() {
	if [ true != "${_hoid__state_default_done:-false}" ]; then
		bobshell_stack_set hoid_state_stack
		_hoid__state_default_done=true
	fi
	hoid_buffer_flush
	hoid_state_init "$@"
	bobshell_event_fire hoid_state_change_event
}

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_subcommand '

	if [ init = "$1" ]; then
		shift
		hoid_sub_init "$@"
		bobshell_result_set true
		return
	fi

	if ! bobshell_isset hoid_target; then
		bobshell_die "hoid target not set"
	fi

	bobshell_result_set false
'



