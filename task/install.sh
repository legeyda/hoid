
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/subcommand.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh
shelduck import ./install/docker.sh

hoid_task_install() {
	bobshell_subcommand hoid_task_install "$@"
}

hoid_task_install_shelduck() {
	hoid script https://github.com/legeyda/shelduck/releases/latest/download/install.sh
}

hoid_task_install_hoid() {
	
	bobshell_die 'not implemented'
	hoid_task_install_hoid_installer=$(shelduck resolve https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh)
	hoid script "$hoid_task_install_hoid_installer"
	unset hoid_task_install_hoid_installer
}

