


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/ssh.sh

# env: hoid_target_address
#      HOID_DRIVER_SSH_*
hoid_driver_ssh_init() {

	hoid_driver_ssh_init_address_1="${HOID_DRIVER_SSH_ADDRESS:-}"

	hoid_driver_ssh_init_address_2="${HOID_DRIVER_SSH_HOST:-}"
	if bobshell_not_empty HOID_DRIVER_SSH_USER && bobshell_not_empty hoid_driver_ssh_init_address_2; then
		hoid_driver_ssh_init_address_2="$HOID_DRIVER_SSH_USER@$hoid_driver_ssh_address"
	fi
	
	if [ -n "$hoid_driver_ssh_init_address_1" ]; then
		if [ -n "$hoid_driver_ssh_init_address_2" ] && [ "$hoid_driver_ssh_init_address_1" != "$hoid_driver_ssh_init_address_1" ]; then
			bobshell_die 'ambigous ssh address'
		fi
		hoid_driver_ssh_address="$hoid_driver_ssh_init_address_1"
	elif [ -n "$hoid_driver_ssh_init_address_2" ]; then
		hoid_driver_ssh_address="$hoid_driver_ssh_init_address_2"
	elif [ -n "${hoid_target_address:-}" ]; then
		hoid_driver_ssh_address="$hoid_target_address"
	else
		bobshell_die 'no ssh address'
	fi

	bobshell_scope_mirror HOID_DRIVER_SSH_ BOBSHELL_SSH_
	unset hoid_driver_ssh_init_address_1 hoid_driver_ssh_init_address_2
}

# env: hoid_driver_ssh_address
hoid_driver_ssh_shell() {
	bobshell_ssh "$hoid_driver_ssh_address" "$1"
}


