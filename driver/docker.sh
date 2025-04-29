
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh

# env: hoid_driver_ssh_address
hoid_driver_docker() {
	docker exec "${HOID_DRIVER_DOCKER_NAME:-$hoid_target}" sh -euc "$1"
}


