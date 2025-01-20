

# mock hoid
shelduck import driver/local.sh

hoid() {
	hoid_task_function="hoid_task_$1"
	if ! bobshell_command_available "$hoid_task_function"; then
		bobshell_die "hoid: task '$1' not found (function '$hoid_task_function' not available)"
	fi
	shift
	"$hoid_task_function" "$@"
	unset hoid_task_function
}

hoid_driver_shell() {
	hoid_driver_local_shell "$@"
}

# flush buffer on success exit
trap '[ $? -eq 0 ] && hoid_task_flush' EXIT