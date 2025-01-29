

#shelduck import https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh
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
	if ! bobshell_isset_1 "$@"; then
		bobshell_die '"hoid shelduck run" requires at least 1 argument'
	fi
	hoid_task_shelduck_run_script=$(shelduck resolve "$1")
	shift
	hoid_task_shelduck_run_args=$(bobshell_quote "$@")

	if [ -n "$hoid_task_shelduck_run_args" ]; then
		hoid script "set -- $hoid_task_shelduck_run_args"
	fi
	hoid script "$hoid_task_shelduck_run_script"

	unset hoid_task_shelduck_run_script hoid_task_shelduck_run_args
}

# fun: hoid shelduck install hoid 
hoid_task_shelduck_install() {


	unset hoid_task_shelduck_install_name
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-n|--name)
				hoid_task_shelduck_install_name=$2
				shift 2
				;;
			(--name=*)
				bobshell_remove_prefix "$1" --name hoid_task_shelduck_install_name
				shift
				;;
			(*)
				break;
				;;
		esac
	done

	if ! bobshell_isset hoid_task_shelduck_install_name; then
		bobshell_die "name required"
	fi
	if [ -z "$hoid_task_shelduck_install_name" ]; then
		bobshell_die "empty name"
	fi

	if ! bobshell_isset_1 "$@"; then
		bobshell_die '"hoid shelduck install" url required'
	fi
	if [ -z "$1" ]; then
		bobshell_die '"hoid shelduck install" unrecognized url: empty'
	fi
	hoid_task_shelduck_install_url="$1"
	shift

	hoid_task_shelduck_install_script=$(shelduck resolve "$hoid_task_shelduck_install_url")
	hoid_task_shelduck_install_script="
hoid_task_shelduck_install_script=$(cat <<HOID_SHELDUCK_INSTALL_EOF
$hoid_task_shelduck_install_script
HOID_SHELDUCK_INSTALL_EOF
)
"
	hoid script "$hoid_task_shelduck_install_script"
	unset hoid_task_shelduck_install_script

	hoid shelduck run "shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/install.sh
bobshell_install_init
bobshell_install_put_executable var:hoid_task_shelduck_install_script '$hoid_task_shelduck_install_name'"

}





