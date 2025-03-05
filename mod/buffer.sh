


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh

bobshell_event_listen hoid_event_cli_usage "printf -- '    -b --buffer    Use buffer true/false
'"

bobshell_event_listen hoid_event_cli_start unset hoid_cli_buffer

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-b|--buffer)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_buffer="$2"
				shift 2
				;;'


hoid_mod_buffer_cli_diff() {
	if bobshell_isset hoid_cli_buffer; then
		if ! bobshell_isset hoid_buffer; then
			return 1
		fi
		if [ "$hoid_cli_buffer" != "$hoid_buffer" ]; then
			return 1
		fi
	fi
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_diff 'hoid_mod_buffer_cli_diff || return 1'




hoid_mod_buffer_state_default() {
	if bobshell_isset HOID_BUFFER; then
		hoid_buffer="$HOID_BUFFER"
	else
		unset hoid_buffer
	fi
}
bobshell_event_listen hoid_event_state_default hoid_mod_buffer_state_default


hoid_mod_buffer_state_dump() {
	if bobshell_isset hoid_buffer; then
		printf 'hoid_state_load_buffer=%s\n' "$hoid_buffer"
	else
		printf '%s\n' "unset hoid_state_load_buffer"
	fi
}
bobshell_event_listen hoid_event_state_dump hoid_mod_buffer_state_dump

hoid_mod_buffer_state_load() {
	if bobshell_isset hoid_state_load_buffer; then
		hoid_set_buffer "$hoid_state_load_buffer"
	else
		unset hoid_buffer
	fi
}
bobshell_event_listen hoid_event_state_load hoid_mod_buffer_state_load

hoid_mod_buffer_init() {
	if bobshell_isset hoid_cli_buffer; then
		hoid_set_buffer "$hoid_cli_buffer"
	elif [ -z "${hoid_buffer:-}" ]; then
		hoid_set_buffer "$HOID_TARGET"
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_buffer_init "$@"'



hoid_set_buffer() {
	if bobshell_isset_1 "$@" && bobshell_isset hoid_buffer && [ "$hoid_buffer" = "$1" ]; then
		return
	fi

	if ! bobshell_isset_1 "$@"; then
		unset hoid_become_password
		return
	fi

	hoid_buffer="$1"

}







bobshell_event_listen hoid_event_task_start  hoid_buffer_flush
bobshell_event_listen hoid_event_task_finish hoid_buffer_flush