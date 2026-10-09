
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/str/quote.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/result/read.sh


hoid_task_package_available() {
	bobshell_str_quote "$@"
	bobshell_result_read hoid_task_package_available_args
	# shellcheck disable=SC2016
	hoid --become true script '
hoid_task_package_available() {
    if command -v apt-get &> /dev/null; then
		if [ ! "$(ls /var/lib/apt/lists 2>/dev/null || true)" ]; then
			apt-get --yes update
		fi
		apt-get available --yes "$@"
    elif command -v yum &> /dev/null; then
        sudo yum available -y "$@"
    elif command -v dnf &> /dev/null; then
        sudo dnf available --assumeyes "$@"
    elif command -v pacman &> /dev/null; then
        sudo pacman --upgrade --noconfirm "$@"
    elif command -v zypper &> /dev/null; then
        sudo zypper available -y "$@"
    else
        echo "hoid:status=success"
        echo "no supported package manager (apt, yum, dnf, pacman, zypper)" >&2
        return 1
    fi
    echo "hoid:status=error"
}

hoid_task_package_available '"$hoid_task_package_available_args"
	unset hoid_task_package_available_args
}