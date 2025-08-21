

#shelduck import https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
# shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/bobshell.sh

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
	unset _hoid_task_shelduck_run__input _hoid_task_shelduck_run__output
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_shelduck_run: option $1: argument expected: locator"
				_hoid_task_shelduck_run__input="$2"
				shift 2
				;;
			(-o|--output)
				bobshell_isset_2 "$@" || bobshell_die "hoid_task_shelduck_run: option $1: argument expected: locator"
				_hoid_task_shelduck_run__output="$2"
				shift 2
				;;
			(-*)
				bobshell_die "hoid_task_shelduck_run: unrecognized option $1"
				;;
			(*)
				break
				;;
		esac
	done
	
	if ! bobshell_isset_1 "$@"; then
		bobshell_die '"hoid shelduck run" requires at least 1 argument'
	fi
	
	hoid_task_shelduck_run_script=$(shelduck resolve "$1")
	shift
	hoid_task_shelduck_run_args=$(bobshell_quote "$@")
	if [ -n "$hoid_task_shelduck_run_script" ]; then
		hoid_task_shelduck_run_script="set -- $hoid_task_shelduck_run_args;
		
$hoid_task_shelduck_run_script"
	fi
	unset hoid_task_shelduck_run_args

	set -- "$hoid_task_shelduck_run_script"
	unset hoid_task_shelduck_run_script
	if bobshell_isset _hoid_task_shelduck_run__input; then
		set -- --input "$_hoid_task_shelduck_run__input" "$@"
		unset _hoid_task_shelduck_run__input
	fi
	if bobshell_isset _hoid_task_shelduck_run__output; then
		set -- --output "$_hoid_task_shelduck_run__output" "$@"
		unset _hoid_task_shelduck_run__output
	fi

	hoid script "$@"
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

	hoid shelduck run "shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/install.sh
bobshell_install_init
bobshell_install_put_executable var:hoid_task_shelduck_install_script '$hoid_task_shelduck_install_name'"

}





