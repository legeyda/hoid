

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/code/defun.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/subcommand.sh


# shellcheck disable=SC2016
bobshell_event_listen hoid_event_subcommand '
	if [ block = "$1" ]; then
		shift
		bobshell_subcommand hoid_sub_block "$@"
		bobshell_result_set true
		return
	fi
	bobshell_result_set false
'

hoid_sub_block_start() {
	hoid_state_push
	hoid_state_init
	bobshell_event_fire hoid_state_change_event
}

hoid_sub_block_end() {
	hoid_state_pop
	bobshell_event_fire hoid_state_change_event
}



