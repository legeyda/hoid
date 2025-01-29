


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/ssh.sh

# env: hoid_target_address
#      HOID_DRIVER_SSH_*
hoid_driver_ssh_init() {
	hoid_driver_ssh_address="${HOID_DRIVER_SSH_ADDRESS:-$hoid_target_address}"
	bobshell_scope_mirror HOID_DRIVER_SSH_ BOBSHELL_SSH_
}

# env: hoid_driver_ssh_address
hoid_driver_ssh_shell() {
	bobshell_ssh "$hoid_driver_ssh_address" "$1"
}


