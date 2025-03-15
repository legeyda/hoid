
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh



hoid_task_install_docker() {
	# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script

	hoid --become true --name 'install docker engine' block start
	
	if ! hoid_task_install_docker_verify ; then
		_hoid_task_install_docker__script=$(bobshell_fetch_url 'https://get.docker.com/') # todo? bobshell_resource_copy 'https://get.docker.com/' var:_hoid_task_install_docker__script
		hoid script "$_hoid_task_install_docker__script"
		unset _hoid_task_install_docker__script
	fi
	hoid_task_install_docker_verify

	# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
	hoid command groupadd docker
	# shellcheck disable=SC2016
	hoid script 'usermod -aG docker $USER'
	hoid command newgrp docker

	# https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot-with-systemd
	hoid command systemctl enable docker.service
	hoid command systemctl enable containerd.service

	hoid block end
}

hoid_task_install_docker_verify() {
	hoid command docker run hello-world
	hoid_buffer_flush
}
