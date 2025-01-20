
# lib dependencies
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/scope.sh
# shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
# shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/install.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/template.sh
# shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/require.sh
# shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/git.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/util.sh



# import std drivers
shelduck import ./driver/docker.sh
shelduck import ./driver/local.sh
shelduck import ./driver/ssh.sh

# import std tasks
shelduck import ./task/command.sh
shelduck import ./task/copy.sh
shelduck import ./task/directory.sh
shelduck import ./task/flush.sh
shelduck import ./task/script.sh
shelduck import ./task/shelduck.sh
shelduck import ./task/shell.sh


# main entry point
hoid() {
	if [ init = "$1" ]; then
		if [ true != "${hoid_init_done:-false}" ]; then
			hoid_task_flush
		fi
		hoid_init "$@"
		hoid_init_done=true
		return
	fi

	if [ true != "${hoid_init_done:-false}" ]; then
		hoid_init
		hoid_init_done=true
	fi

	hoid_task "$@"
}


# txt: 
# env: hoid_target_driver
#      hoid_target_address
hoid_init() {

	# local target
	if bobshell_isset_1 "$@"; then
		hoid_parse_target "$1"
	else
		if bobshell_isset HOID_TARGET; then
			hoid_parse_target "$HOID_TARGET"
		else
			hoid_target_driver=local
		fi

		# todo load profile

		# optionally override
		if bobshell_isset HOID_TARGET_DRIVER; then
			hoid_target_driver="$HOID_TARGET_DRIVER"
		fi
		if bobshell_isset HOID_TARGET_ADDRESS; then
			hoid_target_address="$HOID_TARGET_ADDRESS"
		fi


		# load and init driver
		if bobshell_command_available "hoid_driver_${hoid_target_driver}_init"; then
			"hoid_driver_${hoid_target_driver}_init"
		fi
	fi
	
}




# env: hoid_target_driver
#      hoid_target_address
hoid_parse_target() {
	if ! bobshell_split_first "$1" : hoid_target_driver hoid_target_address; then
		hoid_target_driver=ssh
		hoid_target_address="$1"
	fi
	if ! bobshell_split_first "$hoid_target_address" \; hoid_target_address hoid_target_options; then
		: # todo parse hoid_target_options
	fi
}


hoid_driver_shell() {
	"hoid_driver_${hoid_target_driver}_shell" "set -eu;${bobshell_newline}$*"
}



hoid_task() {
	hoid_task_function="hoid_task_$1"
	if ! bobshell_command_available "$hoid_task_function"; then
		bobshell_die "hoid_task: task '$1' not available"
	fi
	shift
	"$hoid_task_function" "$@"
	unset hoid_task_function
}

# flush buffer on success exit
trap '[ $? -eq 0 ] && hoid_task_flush' EXIT