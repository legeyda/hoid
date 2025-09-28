
hoid_task_package_remove() {
	bobshell_str_quote "$@"
	bobshell_result_read hoid_task_package_remove_args
	hoid --become true script '
hoid_task_package_remove() {
	if command -v apt-get &> /dev/null; then
		apt-get remove --yes "$@"
	elif command -v yum &> /dev/null; then
		yum remove -y "$@"
	elif command -v dnf &> /dev/null; then
		dnf remove --assumeyes "$@"
	elif command -v pacman &> /dev/null; then
		pacman -Rs --noconfirm "$@"
	elif command -v zypper &> /dev/null; then
		zypper remove -y "$@"
	elif command -v apk &> /dev/null; then
		apk del "$@"
	else
		echo "no supported package manager (apt, yum, dnf, pacman, zypper, apk)" >&2
		return 1
	fi
}
hoid_task_package_remove '"$hoid_task_package_remove_args"
	unset hoid_task_package_remove_args
}


