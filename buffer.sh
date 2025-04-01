

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/resource/copy.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/redirect/io.sh

shelduck import ./runtime.sh

hoid_buffer_printf() {
	# shellcheck disable=SC2059
	_hoid_buffer_printf=$(printf "$@")
	hoid_buffer_write "$_hoid_buffer_printf"
	unset _hoid_buffer_printf
}

hoid_buffer_write() {
	hoid_buffer="${hoid_buffer:-}$*"
}

# fun: hoid_buffer_flush
# env: hoid_buffer
hoid_buffer_flush() {
	_hoid_buffer_flush__input=stdin:
	_hoid_buffer_flush__output=stdout:
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
		bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected: locator"
				_hoid_buffer_flush__input="$2"
				shift 2
				;;
			(-o|--output)
		bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected: locator"
				_hoid_buffer_flush__output="$2"
				shift 2
				;;
			(-*)
				bobshell_die "unexpected option: $1"
				;;
			(*)
				bobshell_die "unexpected parameter: $1"
		esac
	done
	if bobshell_isset_1 "$@"; then
		bobshell_die "hoid flush: takes no arguments"
	fi

	if [ -z "${hoid_buffer:-}" ]; then
		return
	fi

	hoid_buffer_rewrite
	if [ -z "${hoid_buffer:-}" ]; then
		return
	fi

	bobshell_event_fire hoid_buffer_flush_start_event
	bobshell_redirect_io "$_hoid_buffer_flush__input" "$_hoid_buffer_flush__output" hoid_driver_write "$hoid_buffer"
	hoid_buffer=
	bobshell_event_fire hoid_buffer_flush_end_event

	unset _hoid_buffer_flush__input _hoid_buffer_flush__output
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



	bobshell_event_fire hoid_event_buffer_rewrite # todo deprecate hoid_event_buffer_rewrite in favor of hoid_buffer_flush_start_event

}
