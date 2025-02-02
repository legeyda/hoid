
# lib dependencies
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/scope.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/template.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/util.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/equals_any.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack.sh

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
shelduck import ./setter.sh
shelduck import ./state.sh


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
	unset hoid_cli_become hoid_cli_target hoid_cli_name
	hoid_cli_opts=false
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-b|--become)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				bobshell_equals_any "$2" true false || bobshell_die "hoid: option $1: argument expected to be either true or false"
				hoid_cli_become=true
				shift 2
				;;
			(-t|--target)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_target="$2"
				shift 2
				;;
			(-n|--name)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_name="$2"
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
	elif [ flush = "$1" ]; then
		if [ true = "$hoid_cli_opts" ]; then
			bobshell_die "hoid flush: options not supported"
		fi
		shift
		hoid_buffer_flush "$@"
	elif [ block = "$1" ]; then
		shift
		hoid_block "$@"
	elif hoid_cli_differ; then
		hoid_state_push
		hoid_state_init
		hoid_task "$@"
		hoid_state_pop
	else
		if [ -z "${hoid_target:-}" ]; then
			hoid_set_target "$HOID_TARGET"
		fi
		if [ -z "${hoid_become:-}" ]; then
			hoid_set_become false
		fi
		hoid_task "$@"
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

'
}



hoid_driver_write() {
	"hoid_driver_${hoid_target_driver}_shell" "$*"
}






# flush buffer on success exit
trap '[ $? -eq 0 ] && hoid_buffer_flush' EXIT