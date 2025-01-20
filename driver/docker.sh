
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh

hoid_driver_docker_init() {
	true # do nothing here
}

# env: hoid_driver_ssh_address
hoid_driver_docker_shell() {
	bobshell_die 'docker driver not implemented'
}


