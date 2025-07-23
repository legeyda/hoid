


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/subcommand.sh

hoid_task_package() {
	bobshell_subcommand hoid_task_package "$@"
}

hoid_task_package_install() {
	hoid --become true   script '
if ! apt-cache show curl 2>/dev/null; then # assume curl is always in repo
	apt-get --yes update
fi
'
	hoid --become true command apt-get --yes install "$@"
}

hoid_task_package_remove() {
	hoid command apt-get --yes uninstall "$@"
}



hoid_task_package_available() {
	for hoid_task_package_available_name in "$@"; do
		# shellcheck disable=SC2016
		hoid --become true --env hoid_task_package_available_name  script '
		if ! apt-cache show "$hoid_task_package_available_name" 2>/dev/null; then # assume curl is always in repo
			echo "" 1>&2
			exit
		fi
'
	done
}