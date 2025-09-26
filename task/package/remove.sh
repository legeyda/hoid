
hoid_task_package_remove() {
	bobshell_str_quote "$@"
	bobshell_result_read hoid_task_package_remove_args
	hoid --become true script '
hoid_task_package_remove() {
    if command -v apt-get &> /dev/null; then
		apt-get remove --yes "$@"
    elif command -v yum &> /dev/null; then
        sudo yum remove -y "$@"
    elif command -v dnf &> /dev/null; then
        sudo dnf remove --assumeyes "$@"
    elif command -v pacman &> /dev/null; then
        sudo pacman -Rs --noconfirm "$@"
    elif command -v zypper &> /dev/null; then
        sudo zypper remove -y "$@"
    else
        echo "no supported package manager (apt, yum, dnf, pacman, zypper)" >&2
        return 1
    fi
}
hoid_task_package_remove '"$hoid_task_package_remove_args"

}


