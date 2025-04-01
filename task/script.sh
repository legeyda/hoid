

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh


hoid_task_script() {
	unset _hoid_task_script__input _hoid_task_script__output
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_script: option $1: argument expected: locator"
				_hoid_task_script__input="$2"
				shift 2
				;;
			(-o|--output)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_script: option $1: argument expected: locator"
				_hoid_task_script__output="$2"
				shift 2
				;;
			(-*)
				bobshell_die "hoid_task_script: unrecognized option $1"
				;;
			(*)
				break
				;;
		esac
	done

	if ! bobshell_isset _hoid_task_script__input && ! bobshell_isset _hoid_task_script__output; then
		hoid_task_script_separator
		bobshell_event_fire hoid_script_start_event
		hoid shell "$@"
		bobshell_event_fire hoid_script_end_event
		return
	fi

	hoid_buffer_flush

	bobshell_event_fire hoid_script_start_event
	hoid shell "$@"
	bobshell_event_fire hoid_script_end_event

	set --
	if bobshell_isset _hoid_task_script__input; then
		set -- "$@" --input "$_hoid_task_script__input"
	fi
	if bobshell_isset _hoid_task_script__output; then
		set -- "$@" --output "$_hoid_task_script__output"
	fi
	
	hoid_buffer_flush "$@"
}




hoid_task_script_separator() {
	while [ -n "${hoid_buffer:-}" ] && ! bobshell_ends_with "$hoid_buffer" "$bobshell_newline$bobshell_newline"; do
		hoid shell "$bobshell_newline"
	done
}