

# mock hoid


hoid() {
	hoid_task_function="hoid_task_$1"
	if ! bobshell_command_available "$hoid_task_function"; then
		bobshell_die "hoid: task '$1' not found (function '$hoid_task_function' not available)"
	fi
	shift
	"$hoid_task_function" "$@"
	unset hoid_task_function
}

hoid_driver_write() {
	sh -c "$1"
}

hoid_buffer_write() {
	hoid_buffer="${hoid_buffer:-}$*"
}

# fun: hoid_buffer_flush
# env: hoid_buffer
hoid_buffer_flush() {
	if bobshell_isset_1 "$@"; then
		bobshell_die "hoid flush: takes no arguments"
	fi
	if [ -n "${hoid_buffer:-}" ]; then
		hoid_driver_write "$hoid_buffer"
		hoid_buffer=
	fi
}

# flush buffer on success exit
trap '[ $? -eq 0 ] && hoid_buffer_flush' EXIT