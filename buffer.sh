

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

shelduck import ./runtime.sh


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
		hoid_buffer_rewrite
		hoid_driver_write "$hoid_buffer"
		hoid_buffer=
	fi
}


hoid_buffer_rewrite() {


	hoid_buffer_rewrite_tasks=$(printf %s "$hoid_buffer" | sed -n 's/\(^\|[[:space:]]\)hoid\s\+\([A-Za-z_][A-Za-z0-9_-]*\).*$/\2/gp')

	if [ -n "$hoid_buffer_rewrite_tasks" ]; then
		hoid_buffer_rewrite_tasks="${hoid_buffer_rewrite_tasks}${bobshell_newline}command${bobshell_newline}script${bobshell_newline}shell"
		hoid_buffer_rewrite_tasks=$(printf %s "$hoid_buffer_rewrite_tasks" | sort -u)
		
		hoid_buffer_rewrite_orig="$hoid_buffer"
		hoid_buffer=

		# hoid remote mock
		hoid_buffer_rewrite_src=$(hoid_remote_mock_src)
		hoid script "$hoid_buffer_rewrite_src"
		unset hoid_buffer_rewrite_src
		
		# hoid all task scriptes
		for hoid_buffer_rewrite_task in $hoid_buffer_rewrite_tasks; do
			if ! bobshell_command_available "hoid_task_${hoid_buffer_rewrite_task}_src"; then
				bobshell_die "hoid_task_shell: task '$hoid_buffer_rewrite_task' not supported in shell mode"
			fi
			hoid_buffer_rewrite_src=$("hoid_task_${hoid_buffer_rewrite_task}_src")
			hoid script "$hoid_buffer_rewrite_src"
			unset hoid_buffer_rewrite_src
		done
		unset hoid_buffer_rewrite_task hoid_buffer_rewrite_tasks

		hoid_buffer_write "${bobshell_newline}${bobshell_newline}$hoid_buffer_rewrite_orig"
		unset hoid_buffer_rewrite_orig
	fi

	hoid_buffer="${bobshell_newline}${bobshell_newline}set -eu${bobshell_newline}$hoid_buffer"

	if [ "$hoid_become" = true ]; then
		if bobshell_contains "$hoid_buffer" "'"; then
			hoid_buffer="sudo sh -c '$hoid_buffer'"
		else
			bobshell_buffer_rewrite_random="$(bobshell_random)$(bobshell_random)$(bobshell_random)"
			hoid_buffer="script=$(cat<<EOF_$bobshell_buffer_rewrite_random
$hoid_buffer
EOF_$bobshell_buffer_rewrite_random
)"
			hoid_buffer="$hoid_buffer

sudo sh -c \"\$script\""
		fi


	fi


}
