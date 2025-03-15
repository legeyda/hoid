


# fun: hoid_sub_init 
hoid_sub_init() {
	hoid_buffer_flush
	hoid_state_init "$@"
	_hoid__state_default_done=true
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_event_subcommand '
	if [ init = "$1" ]; then
		shift
		hoid_sub_init "$@"
		return
	fi
'



