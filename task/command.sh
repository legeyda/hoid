
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh



hoid_task_command() {
	unset _hoid_task_command__input _hoid_task_command__output
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_command: option $1: argument expected: locator"
				_hoid_task_command__input="$2"
				shift 2
				;;
			(-o|--output)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_command: option $1: argument expected: locator"
				_hoid_task_command__output="$2"
				shift 2
				;;
			(-*)
				bobshell_die "hoid_task_command: unrecognized option $1"
				;;
			(*)
				break
				;;
		esac
	done
	_hoid_task_command=$(bobshell_quote "$@")

	set --
	if bobshell_isset _hoid_task_command__input; then
		set -- "$@" --input "$_hoid_task_command__input"
		unset _hoid_task_command__input
	fi
	if bobshell_isset _hoid_task_command__output; then
		set -- "$@" --output "$_hoid_task_command__output"
		unset _hoid_task_command__output
	fi

	hoid script "$@" "${_hoid_task_command}${bobshell_newline}"
	unset _hoid_task_command
}