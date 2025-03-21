

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

hoid_task_script_cli() {
	_hoid_task_script_cli__delegate="$1"
	shift

	unset _hoid_task_script_cli__input _hoid_task_script_cli__output
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_script: option $1: argument expected: locator"
				_hoid_task_script_cli__input="$2"
				shift 2
				;;
			(-o|--output)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_script: option $1: argument expected: locator"
				_hoid_task_script_cli__output="$2"
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

	"$_hoid_task_script_cli__delegate" "$@"
	unset _hoid_task_script_cli__delegate
}

hoid_task_script() {
	hoid_task_script_cli hoid_task_script_go "$@"
}

hoid_task_script_go() {
	
	if ! bobshell_isset _hoid_task_script_cli__input && ! bobshell_isset _hoid_task_script_cli__output; then
		hoid_task_script_separator
		hoid shell "$@"
		return
	fi

	hoid_buffer_flush

	hoid shell "$@"

	set --
	if bobshell_isset _hoid_task_script_cli__input; then
		set -- "$@" --input "$_hoid_task_script_cli__input"
	fi
	if bobshell_isset _hoid_task_script_cli__output; then
		set -- "$@" --output "$_hoid_task_script_cli__output"
	fi
	
	hoid_buffer_flush "$@"
}

hoid_task_script_separator() {
	while [ -n "${hoid_buffer:-}" ] && ! bobshell_ends_with "$hoid_buffer" "$bobshell_newline$bobshell_newline"; do
		hoid shell "$bobshell_newline"
	done
}