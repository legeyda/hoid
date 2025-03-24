

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/array/set.sh


hoid_redirect() {
	_hoid_redirect__delegate="$1"
	shift

	unset _hoid_redirect__input _hoid_redirect__output
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_script: option $1: argument expected: locator"
				_hoid_redirect__input="$2"
				shift 2
				;;
			(-o|--output)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_script: option $1: argument expected: locator"
				_hoid_redirect__output="$2"
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


	set -- "$_hoid_redirect__delegate" "$@"
	unset _hoid_redirect__delegate
	if bobshell_isset _hoid_task_script_cli__input; then
		set -- --input "$_hoid_task_script_cli__input" "$@"
	fi
	if bobshell_isset _hoid_task_script_cli__output; then
		set -- --output "$_hoid_task_script_cli__output" "$@"
	fi

	"$@"
}