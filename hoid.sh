
# lib dependencies
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/util.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/equals_any.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/fire.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/template.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/result/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/result/check.sh


# import std tasks
shelduck import ./task/command.sh
shelduck import ./task/copy.sh
shelduck import ./task/directory.sh
shelduck import ./task/script.sh
shelduck import ./task/shelduck.sh
shelduck import ./task/shell.sh
shelduck import ./task/reboot.sh
shelduck import ./task/git.sh
shelduck import ./task/docker.sh
shelduck import ./task/install.sh

# import std drivers
shelduck import ./driver/docker.sh
shelduck import ./driver/local.sh
shelduck import ./driver/ssh.sh

#
shelduck import ./mod/all.sh

# private dependencies
shelduck import ./state.sh
shelduck import ./setup.sh

# main entry point
hoid() {
	: "${_hoid_recursion_depth=0}"
	_hoid_recursion_depth=$(( _hoid_recursion_depth + 1 ))

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

	hoid_setup_ensure

	hoid_cli_parse "$@"

	_hoid_recursion_depth=$(( _hoid_recursion_depth - 1 ))
}

hoid_assert_no_recursion() {
	if [ "$_hoid_recursion_depth" -gt 1 ]; then
		_hoid_assert_no_recursion__message='hoid_assert_no_recursion: assertion failed'
		if bobshell_isset "$@"; then
			_hoid_assert_no_recursion__message="$_hoid_assert_no_recursion__message: $*"
			bobshell_die "$_hoid_assert_no_recursion__message"
		fi
	fi
}

hoid_usage() {
	printf %s 'Usage: hoid [OPTIONS] command

Commands:
	init
	become

Options:'
	bobshell_event_fire hoid_event_cli_usage
}


hoid_cli_parse() {
	# parse hoid cli (common for all tasks)
	bobshell_event_fire hoid_event_cli_start
	hoid_cli_opts=false
	bobshell_event_fire hoid_event_cli_options "$@"
}


# shellcheck disable=SC2016
bobshell_event_template hoid_event_cli_options '
	while bobshell_isset_1 "$@"; do
		case "$1" in
			{}
			(-*)
				bobshell_die "hoid: unrecognized option $1"
				;;
			(*)
				break
				;;
		esac
		hoid_cli_opts=true
	done
	hoid_subcommand "$@"'


hoid_subcommand() {
	# check if task is defined
	if ! bobshell_isset_1 "$@"; then
		printf %s 'hoid: command expected' 2>&1
		hoid_usage 2>&1
		exit 1
	fi

	bobshell_result_set false
	bobshell_event_fire hoid_event_subcommand "$@"
	if bobshell_result_check; then
		return
	fi

	bobshell_event_fire hoid_alt_diff_event
	if bobshell_result_check; then
		if [ copy != "$1" ] || [ "$_hoid_recursion_depth" -le 1 ]; then
			hoid_state_validate
		fi
		hoid_task "$@"
	else
		hoid_assert_no_recursion hoid cli arguments
		hoid_state_push
		hoid_state_init
		hoid_state_validate
		bobshell_event_fire hoid_state_change_event
		hoid_task "$@"
		hoid_state_pop
		bobshell_event_fire hoid_state_change_event
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




hoid_driver_write() {
	"hoid_driver_${hoid_driver}" "$*"
}




bobshell_event_listen bobshell_success_exit_event hoid_success_exit_event
hoid_success_exit_event() {
	hoid_buffer_flush
}

bobshell_event_listen bobshell_error_exit_event hoid_error_exit_event_listener
hoid_error_exit_event_listener() {
	printf %s 'HOID: THERE WAS AN ERROR'
}