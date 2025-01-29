
# lib dependencies
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/scope.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/template.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/util.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/str/equals.sh

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

shelduck import ./buffer.sh
shelduck import ./init.sh


# main entry point
hoid() {
	# no arguments
	if ! bobshell_isset_1 "$@"; then
		hoid_usage 2>&1
		exit 1
	fi

	# print usage
	if bobshell_equals "$1" -h --help -? usage help && ! bobshell_isset_2 "$@" ; then
		hoid_usage
		return
	fi

	# explicit init
	if [ init = "$1" ]; then
		shift
		hoid_buffer_flush
		hoid_init "$@"
		hoid_init_done=true
		return
	fi

	# implicit init
	if [ true != "${hoid_init_done:-false}" ]; then
		hoid_buffer_flush
		hoid_init
		hoid_init_done=true
	fi

	# flush
	if [ flush = "$1" ] && ! bobshell_isset_2 "$@"; then
		hoid_buffer_flush
		return
	fi

	# delegate to task
	hoid_task "$@"
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







hoid_task() {
	unset hoid_task_become
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-b|--become|--become=true)
				shift
				hoid_task_become=true ;;
			(--become=false)
				shift
				hoid_task_become=false ;;
			(-*)
				bobshell_die "unrecognized option $1" ;;
			(*)
				break ;;
		esac
	done

	


	hoid_task_function="hoid_task_$1"
	if ! bobshell_command_available "$hoid_task_function"; then
		bobshell_die "hoid_task: task '$1' not available"
	fi
	shift
	"$hoid_task_function" "$@"
	unset hoid_task_function
}

# flush buffer on success exit
trap '[ $? -eq 0 ] && hoid_buffer_flush' EXIT