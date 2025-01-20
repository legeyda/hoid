
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

shelduck import ../runtime.sh

# hoid buffer flush
hoid_task_flush() {
	if [ -n "${hoid_buffer:-}" ]; then
		set -- "$hoid_buffer"
		hoid_buffer=
		hoid_task_shell2 "$@"

		hoid_driver_shell "$hoid_buffer"
		hoid_buffer=
	fi
}

hoid_task_shell2() {

	hoid_task_shell2_tasks=$(printf %s "$*" | sed -n 's/\(^\|[[:space:]]\)hoid\s\+\([A-Za-z_][A-Za-z0-9_-]*\).*$/\2/gp')
	hoid_task_shell2_tasks="${hoid_task_shell2_tasks}${bobshell_newline}command${bobshell_newline}flush${bobshell_newline}script${bobshell_newline}shell"
	hoid_task_shell2_tasks=$(printf %s "$hoid_task_shell2_tasks" | sort -u)


	if [ -n "$hoid_task_shell2_tasks" ]; then
		# hoid remote mock
		hoid_task_shell2_src=$(hoid_remote_mock_src)
		hoid script "$hoid_task_shell2_src"
		unset hoid_task_shell2_src
		
		# hoid all task scriptes
		for hoid_task_shell2_task in $hoid_task_shell2_tasks; do
			if ! bobshell_command_available "hoid_task_${hoid_task_shell2_task}_src"; then
				bobshell_die "hoid_task_shell: task '$hoid_task_shell2_task' not supported in shell mode"
			fi
			hoid_task_shell2_src=$("hoid_task_${hoid_task_shell2_task}_src")
			hoid script "$hoid_task_shell2_src"
			unset hoid_task_shell2_src
		done
		unset hoid_task_shell2_task hoid_task_shell2_tasks
	fi

	hoid_task_script "$@"
}

