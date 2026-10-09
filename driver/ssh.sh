


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/ssh.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/scope.sh

# env: hoid_driver_ssh_address
hoid_driver_ssh() {
	bobshell_scope_mirror HOID_DRIVER_SSH_ BOBSHELL_SSH_
	#bobshell_log_error write length: "${#1}"

	printf %s "$1" > ~/cur/ssh-command.txt
	printf %s "${HOID_DRIVER_SSH_ADDRESS:-$hoid_target}" > ~/cur/ssh-address.txt

	local cmd="$*"
	bobshell_log_trace "$cmd"
	if [ ${#cmd} -lt 65536 ]; then
		bobshell_ssh "${HOID_DRIVER_SSH_ADDRESS:-$hoid_target}" "$*"
	else
		local random_str="$(bobshell_random)$(bobshell_random)$(bobshell_random)"
		printf %s "$cmd" | bobshell_ssh "${HOID_DRIVER_SSH_ADDRESS:-$hoid_target}" "cat > /tmp/$random_str"
		bobshell_ssh "${HOID_DRIVER_SSH_ADDRESS:-$hoid_target}" ". /tmp/$random_str; rm -f /tmp/$random_str"
	fi

}
