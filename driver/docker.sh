
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh

# env: hoid_driver_ssh_address
hoid_driver_docker() {
	docker exec --interactive "${HOID_DRIVER_DOCKER_NAME:-$hoid_target}" sh -c 'set +eu
if [ $(id -u) -eq 0 ]; then
	. /etc/profile
else
	. "$HOME/.profile"
fi


set -eu
'"$1"
}


