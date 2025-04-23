
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh

hoid_driver_docker_init() {
	hoid_driver_docker_name="${HOID_DRIVER_DOCKER_NAME:-$hoid_target}"
}

# env: hoid_driver_ssh_address
hoid_driver_docker_shell() {
	docker exec "$hoid_driver_docker_name" sh -euc "$1"
}


