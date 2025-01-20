
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh



hoid_task_command() {
	if [ -n "${hoid_buffer:-}" ] && ! bobshell_ends_with "$hoid_buffer" "$bobshell_newline"; then
		hoid shell "$bobshell_newline"
	fi

	hoid_task_command=$(bobshell_quote "$@")
	hoid shell "$hoid_task_command"
	unset hoid_task_command

	hoid shell "${bobshell_newline}"
}