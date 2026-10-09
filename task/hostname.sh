
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/misc/subcommand.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/url.sh
shelduck import ./install/docker.sh

_hoid_task_hostname__script=$(cat <<'EOF'
set -eu



hoid_task_hostname() {
	: "${_hoid_task_hostname__destdir:=}

	# get old hostname
	if   command -v hostnamectl > /dev/null; then
		_hoid_task_hostname__old=$(hostnamectl hostname)
	elif command -v hostname    > /dev/null; then
		_hoid_task_hostname__old=$(hostname)
	else
		_hoid_task_hostname__old=$(cet "$_hoid_task_hostname__destdir"/etc/hostname)
	fi

	# only if hostname actually changed
	if [ "$_hoid_task_hostname__old" != "$1" ]; then

		# change hostname to new value
		if   command -v hostnamectl > /dev/null; then
			hostnamectl set-hostname "$1"
		elif command -v hostname    > /dev/null; then
			hostname "$1"
		else
			printf '%s\n' "$1" > "$_hoid_task_hostname__destdir"/etc/hostname
		fi

		# get old /etc/hosts content
		_hoid_task_hostname__oldhosts=$(cat "$_hoid_task_hostname__destdir"/etc/hosts)

		# update /etc/hosts
		hoid_task_hostname__newhosts=$(printf %s "$_hoid_task_hostname__oldhosts" |
				sed 'd/^[[:blank:]]*127\.0\.0\.1[[:blank:]]\+'"$1"'[[:blank:]]*$')
		hoid_task_hostname__newhosts=$(printf %s "$hoid_task_hostname__newhosts" |
				sed 's/^\([[:blank:]]*127\.0\.0\.1.*[[:blank:]]\)'"$1"'\([[:blank:]]\)$/\1/g;')



		_hoid_task_hostname__sed=
		_hoid_task_hostname__sed='s/^\(xyz\)/\1/g;'
		hoid_task_hostname__newhosts=$(printf %s "$_hoid_task_hostname__oldhosts" | sed "$_hoid_task_hostname__sed")
		unset _hoid_task_hostname__sed

		# only if content actually changed
		if [ "$_hoid_task_hostname__oldhosts" != "$_hoid_task_hostname__newhosts" ]; then
			
			# backup
			_hoid_task_hostname__now=$(date +%y-%m-%d_%H-%M-%S)
			_hoid_task_hostname__backup="$_hoid_task_hostname__destdir"/etc/hosts_backup_hoid_$_hoid_task_hostname__now
			cp "$_hoid_task_hostname__destdir"/etc/hostname $_hoid_task_hostname__backup

			# overwrite
			printf '%s\n' "$_hoid_task_hostname__newhosts" > "$_hoid_task_hostname__destdir"/etc/hosts
		fi 

		unset _hoid_task_hostname__oldhosts hoid_task_hostname__newhosts
	fi

	unset _hoid_task_hostname__old
}

hoid_task_hostname "$_hoid_task_hostname__newvalue"

EOF
)

hoid_task_hostname() {
	bobshell_regex_match '^([a-zA-Z0-9][-a-zA-Z0-9]{0,62})(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})*$' "$1" \
		|| bobshell_die "hoid hostname: invalid hostname: $1"
	hoid --env _hoid_task_hostname__newvalue="$1" --env _hoid_task_hostname__destdir= script "$_hoid_task_hostname__script"
}

