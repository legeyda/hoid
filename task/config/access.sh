


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/cli/setup.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/cli/parse.sh



bobshell_cli_setup hoid_task_config_access_cli --var=_hoid_task_config_access__tenant --param --default-value=hoid t tenant
bobshell_cli_setup hoid_task_config_access_cli --var=_hoid_task_config_access__user --param --default-value=hoidadmin u user-name
bobshell_cli_setup hoid_task_config_access_cli --var=_hoid_task_config_access__sudo --flag s sudo

hoid_task_config_access() {
	hoid --become true --name 'config access' block start
	
	bobshell_cli_parse hoid_task_config_access_cli "$@"
	shift "$bobshell_cli_shift"

	
	mkdir -p "$HOME/.ssh/$_hoid_task_config_access__tenant"
	
# shellcheck disable=SC2154
	cat > "$HOME/.ssh/$_hoid_task_config_access__tenant/config" <<EOF
Host $_hoid_task_config_access__tenant $hoid_target
    Hostname $hoid_target
    User $_hoid_task_config_access__user
    IdentityFile $HOME/.ssh/$_hoid_task_config_access__tenant/$_hoid_task_config_access__user
EOF
	chmod 600 "$HOME/.ssh/$_hoid_task_config_access__tenant/config"
	
	#ssh-keyscan "${HOID_DRIVER_SSH_ADDRESS:-$hoid_target}" >> "$HOME/.ssh/authorized_keys"

	hoid_util_backup "$HOME/.ssh/$_hoid_task_config_access__tenant/$_hoid_task_config_access__user" "$HOME/.ssh/$_hoid_task_config_access__tenant/$_hoid_task_config_access__user.pub"
	ssh-keygen -t ed25519 -f "$HOME/.ssh/$_hoid_task_config_access__tenant/$_hoid_task_config_access__user" -P ''

	hoid user --ssh-copy-id --ssh-id-file="$HOME/.ssh/$_hoid_task_config_access__tenant/$_hoid_task_config_access__user" "$_hoid_task_config_access__user"
	
	# todo when using sudo password:
	# redirec does
	
	# config sudo without password
	if [ true = "$_hoid_task_config_access__sudo" ]; then
		hoid script "printf %s '$_hoid_task_config_access__user	ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/$_hoid_task_config_access__user"
		hoid command chmod u=r,g=r "/etc/sudoers.d/$_hoid_task_config_access__user"
	fi

	hoid block end
}
# fun: hoid_util_backup [FILES...]
hoid_util_backup() {
	while bobshell_isset_1 "$@"; do
		if [ -f "$1" ]; then
			: "${_hoid_util_backup__now:=$(date +%y-%m-%d_%H-%M-%S)}"
			mv "$1" "${1}_backup_$_hoid_util_backup__now"
		fi
		shift
	done
	unset _hoid_util_backup__now
}