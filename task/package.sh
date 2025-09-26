
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/misc/subcommand.sh

shelduck import ./package/install.sh
shelduck import ./package/remove.sh

hoid_task_package() {
	bobshell_subcommand hoid_task_package "$@"
}
