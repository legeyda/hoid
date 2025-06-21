
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/result/set.sh



hoid_task_install_docker() {
	# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
	set -x
	hoid --become true --name 'install docker engine' block start
	
	hoid_task_install_docker_verify
	if ! bobshell_result_check; then
		_hoid_task_install_docker__script=$(bobshell_fetch_url 'https://get.docker.com/') # todo? bobshell_resource_copy 'https://get.docker.com/' var:_hoid_task_install_docker__script
		hoid script "set +eu; $_hoid_task_install_docker__script"
		unset _hoid_task_install_docker__script

		hoid_task_install_docker_verify
		if ! bobshell_result_check; then
			bobshell_die 'something wrong: docker invalid after installation'
		fi
	fi

	# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
	hoid script 'groupadd docker || true'
	# shellcheck disable=SC2016
	hoid script 'if [ "$USER" != root ]; then # todo always true
		usermod -aG docker $USER
	fi'
	#hoid command newgrp docker

	# https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot-with-systemd
	hoid command systemctl enable docker.service
	hoid command systemctl enable containerd.service

	hoid block end
}



hoid_task_install_docker_verify() {
	hoid_buffer_flush
	hoid script 'docker run hello-world && echo docker_run_success_af7b2df8f59c4241ba6cdd3033cdfae1b2d53089b7944afc8828666914a8527c || true'
	hoid_buffer_flush --output var:_hoid_task_install_docker_verify
	if bobshell_contains "$_hoid_task_install_docker_verify" docker_run_success_af7b2df8f59c4241ba6cdd3033cdfae1b2d53089b7944afc8828666914a8527c; then
		bobshell_result_set true
	else
		bobshell_result_set false
	fi
}
