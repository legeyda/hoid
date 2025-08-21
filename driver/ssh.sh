


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/ssh.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/scope.sh

# env: hoid_driver_ssh_address
hoid_driver_ssh() {
	bobshell_scope_mirror HOID_DRIVER_SSH_ BOBSHELL_SSH_
	bobshell_ssh "${HOID_DRIVER_SSH_ADDRESS:-$hoid_target}" "$1"
}


