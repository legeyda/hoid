
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/str/quote.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/result/read.sh


hoid_task_package_install() {
	bobshell_str_quote "$@"
	bobshell_result_read hoid_task_package_install_args
	# shellcheck disable=SC2016
	hoid --become true script '
hoid_task_package_install() {
    if command -v apt-get &> /dev/null; then
		if [ ! "$(ls /var/lib/apt/lists 2>/dev/null || true)" ]; then
			apt-get --yes update
		fi
		apt-get install --yes "$@"
    elif command -v yum &> /dev/null; then
        yum install -y "$@"
    elif command -v dnf &> /dev/null; then
        dnf install --assumeyes "$@"
    elif command -v pacman &> /dev/null; then
        pacman -S --noconfirm "$@"
    elif command -v zypper &> /dev/null; then
        zypper install -y "$@"
    elif command -v apk &> /dev/null; then
        apk add "$@"
    else
        echo "no supported package manager (apt, yum, dnf, pacman, zypper, apk)" >&2
        return 1
    fi
}

hoid_task_package_install '"$hoid_task_package_install_args"
	unset hoid_task_package_install_args
}