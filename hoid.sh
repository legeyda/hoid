
# lib dependencies
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/scope.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/template.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/util.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/equals_any.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/fire.sh

# import std drivers
shelduck import ./driver/docker.sh
shelduck import ./driver/local.sh
shelduck import ./driver/ssh.sh

# import std tasks
shelduck import ./task/command.sh
shelduck import ./task/copy.sh
shelduck import ./task/directory.sh
shelduck import ./task/script.sh
shelduck import ./task/shelduck.sh
shelduck import ./task/shell.sh

# private dependencies
shelduck import ./block.sh
shelduck import ./buffer.sh
shelduck import ./state.sh

#
shelduck import ./mod/name.sh
shelduck import ./mod/target.sh
shelduck import ./mod/become.sh

# main entry point
hoid() {
	# no arguments
	if ! bobshell_isset_1 "$@"; then
		hoid_usage 2>&1
		exit 1
	fi

	# print usage
	if bobshell_equals_any "$1" -h --help -? usage help && ! bobshell_isset_2 "$@" ; then
		hoid_usage
		return
	fi

	# parse hoid cli (common for all tasks)
	bobshell_event_fire hoid_event_cli_start
	hoid_cli_opts=false
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-n|--name)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				shift 2
				;;
			(-t|--target)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_target="$2"
				shift 2
				;;
			(-b|--become)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				bobshell_equals_any "$2" true false || bobshell_die "hoid: option $1: argument expected to be either true or false"
				hoid_cli_become="$2"
				shift 2
				;;
			(-p|--become-password)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_become_password="$2"
				shift 2
				;;
			(-*)
				bobshell_die "hoid: unrecognized option $1"
				;;
			(*)
				break
				;;
		esac
		hoid_cli_opts=true
	done


	# check if task is defined
	if ! bobshell_isset_1 "$@"; then
		printf %s 'hoid: command expected' 2>&1
		hoid_usage 2>&1
		exit 1
	fi


	# subcommand
	if [ init = "$1" ]; then
		shift
		hoid_buffer_flush
		hoid_state_init "$@"
		_hoid__state_default_done=true
	else	
		if [ true != "${_hoid__state_default_done:-false}" ]; then
			bobshell_event_fire hoid_event_state_default
			_hoid__state_default_done=true
		fi
		if [ flush = "$1" ]; then
			if [ true = "$hoid_cli_opts" ]; then
				bobshell_die "hoid flush: options not supported"
			fi
			shift
			hoid_buffer_flush "$@"
		elif [ block = "$1" ]; then
			shift
			hoid_block "$@"
		elif ! bobshell_event_fire hoid_event_cli_diff; then
			hoid_state_push
			hoid_state_init
			hoid_task "$@"
			hoid_state_pop
		else
			hoid_task "$@"
		fi
	fi

}

hoid_task() {
	hoid_task_function="hoid_task_$1"
	if ! bobshell_command_available "$hoid_task_function"; then
		bobshell_die "hoid: task '$1' not available"
	fi
	shift
	"$hoid_task_function" "$@"
	unset hoid_task_function
}

hoid_usage() {
	printf %s 'Usage: hoid [OPTIONS] command

Commands:
	init
	become

Options:'
	bobshell_event_fire hoid_event_cli_usage
}



hoid_driver_write() {
	"hoid_driver_${hoid_target_driver}_shell" "$*"
}






# flush buffer on success exit
trap '[ $? -eq 0 ] && hoid_buffer_flush' EXIT