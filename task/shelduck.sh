

shelduck import https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
# shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/bobshell.sh

hoid_task_shelduck() {
	case "$1" in 
		(run|install)
			hoid_task_shelduck_subcommand="$1"
			shift
			"hoid_task_shelduck_$hoid_task_shelduck_subcommand" "$@"
			;;
		(*)
			bobshell_die "shelduck: subcommand '$1' not supported"
			;;
	esac
}


# fun: hoid_task_shelduck_run SHELDUCKARGS
hoid_task_shelduck_run() {
	hoid_task_shelduck_run=$(hoid_task_shelduck_script "$@")
	hoid_driver_shell "$hoid_task_shelduck_run"
	unset hoid_task_shelduck_run
}

hoid_task_shelduck_script() {
	shelduck_parse_cli "$@"

	if [ -n "${shelduck_parse_cli_url:-}" ]; then
		printf 'set --'
		eval "bobshell_quote ${shelduck_parse_cli_args:-}"
		printf '\n\n'

		shelduck resolve $(printf ' --alias %s' ${hoid_task_shelduck_aliases:-}) "$shelduck_parse_cli_url"
		printf '\n\n'
	fi
	unset shelduck_parse_cli_aliases shelduck_parse_cli_url


	if [ -n "${shelduck_parse_cli_command:-}" ]; then
		printf 'set --'
		eval "bobshell_quote ${shelduck_parse_cli_args:-}"
		printf '\n\n'

		printf %s "${shelduck_parse_cli_command:-}"
	fi
	unset shelduck_parse_cli_command shelduck_parse_cli_args
}



# fun: hoid shelduck install hoid 
hoid_task_shelduck_install() {
	hoid_task_shelduck_install=$(hoid_task_shelduck_script "$@")

	hoid_task_shelduck_run 'https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/install.sh'
}





