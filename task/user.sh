




shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

# cli parse
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/cli/setup.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/cli/parse.sh



bobshell_cli_setup hoid_task_user_cli --var=_hoid_task_user__groups --param G groups
bobshell_cli_setup hoid_task_user_cli --var=_hoid_task_user__home --param d home
bobshell_cli_setup hoid_task_user_cli --var=_hoid_task_user__uid --param u uid
bobshell_cli_setup hoid_task_user_cli --var=_hoid_task_user__ssh_copy_id --flag ssh-copy-id
bobshell_cli_setup hoid_task_user_cli --var=_hoid_task_user__ssh_id_file --param i ssh-id-file

# use: hoid_task_user --ssh-copy-id "$HOME/.ssh/ubuntu24server/wongadmin" --ssh-keygen always
# use: hoid_task_user --ssh-copy-id --ssh-id-file "$HOME/.ssh/ubuntu24server/wongadmin" --ssh-keygen
hoid_task_user() {
	bobshell_cli_parse hoid_task_user_cli "$@"
	shift "$bobshell_cli_shift"


	# shellcheck disable=SC2016
	# shellcheck disable=SC2154
	hoid --env "hoid_task_user_name=$1" script 'test $(getent group  "$hoid_task_user_name") || groupadd "$hoid_task_user_name"'

	_hoid_task_user__useradd_args=' -s /usr/bin/bash'
	if bobshell_isset _hoid_task_user__home; then
		_hoid_task_user__qhome=$(bobshell_quote "$_hoid_task_user__home")
		_hoid_task_user__useradd_args="$_hoid_task_user__useradd_args --home $_hoid_task_user__qhome"
		unset _hoid_task_user__qhome
	fi
	if bobshell_isset _hoid_task_user__uid; then
		_hoid_task_user__quid=$(bobshell_quote "$_hoid_task_user__uid")
		_hoid_task_user__useradd_args="$_hoid_task_user__useradd_args --uid $_hoid_task_user__quid"
		unset _hoid_task_user__quid
	fi
	
	# shellcheck disable=SC2016
	hoid --env "hoid_task_user_name=$1" script '# hoid_task_user: ensure user
if [ $(getent passwd "$hoid_task_user_name") ]; then
	usermod --gid "$hoid_task_user_name" '"$_hoid_task_user__useradd_args"' "$hoid_task_user_name"
else
	useradd --gid "$hoid_task_user_name" '"$_hoid_task_user__useradd_args"' "$hoid_task_user_name"
fi
passwd -l "$hoid_task_user_name"
'

	# shellcheck disable=SC2016
	hoid --env "hoid_task_user_name=$1" script '# hoid_task_user: ensure home
hoid_task_user_home="$(eval "echo ~$hoid_task_user_name")"
mkdir -p "$hoid_task_user_home"
chown "$hoid_task_user_name:$hoid_task_user_name" "$hoid_task_user_home"  
chmod u=rwx,g=rx,o= "$hoid_task_user_home"'

	# if ssh-copy-id
	if [ true = "$_hoid_task_user__ssh_copy_id" ]; then

		#
		if bobshell_isset _hoid_task_user__ssh_id_file; then
			_hoid_task_user__ssh_default_file=false
		else
			_hoid_task_user__ssh_default_file=true
			_hoid_task_user__ssh_id_file="$HOME/.ssh/id_$_hoid_task_user__ssh_key_type"
		fi

		bobshell_remove_suffix "$_hoid_task_user__ssh_id_file" .pub _hoid_task_user__ssh_id_file || true

		if ! [ -f "$_hoid_task_user__ssh_id_file.pub" ]; then
			bobshell_die "hoid user: user identity (public key) not found (try --ssh-keygen): $_hoid_task_user__ssh_id_file.pub"
		fi

		# copy id
		_hoid_task_user__id=$(cat "$_hoid_task_user__ssh_id_file.pub")
		# shellcheck disable=SC2016
		hoid --env "hoid_task_user_name=$1" --env "hoid_task_user_key=$_hoid_task_user__id" script '# hoid_task_user: copy id	
hoid_task_user_home="$(eval "echo ~$hoid_task_user_name")"
mkdir -p "$hoid_task_user_home/.ssh"
chown "$hoid_task_user_name:$hoid_task_user_name" "$hoid_task_user_home/.ssh"

if ! [ -f "$hoid_task_user_home/.ssh/authorized_keys" ] || ! grep -q -- "$hoid_task_user_key" "$hoid_task_user_home/.ssh/authorized_keys" ; then
	printf "%s\n" "$hoid_task_user_key" >> "$hoid_task_user_home/.ssh/authorized_keys"
fi
chown "$hoid_task_user_name:$hoid_task_user_name" "$hoid_task_user_home/.ssh/authorized_keys"
chmod u=rw,g=,o= "$hoid_task_user_home/.ssh/authorized_keys"
unset hoid_task_user_home
'


	fi

}