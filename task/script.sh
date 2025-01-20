

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

hoid_task_script() {
	while [ -n "${hoid_buffer:-}" ] && ! bobshell_ends_with "$hoid_buffer" "$bobshell_newline$bobshell_newline"; do
		hoid shell "$bobshell_newline"
	done
	hoid shell "$@"
}
