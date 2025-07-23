



shelduck import ./lineinfile.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/str/quote.sh


hoid_task_path_function=$(cat<<'EOF'
# fun: hoid_task_path PATH
# env: hoid_task_path_configs
hoid_task_path() {

	# skip if already in path
	case "$PATH" in
		(*$1*) return
	esac

	case "$1" in
		(*\'*) echo "hoid_task_path: single quotes not supported: $1" # todo" 1>&2; return 1
	esac

	if [ -n "${hoid_task_path_configs:-}" ]; then
		_hoid_task_path__cfgs="$hoid_task_path_configs"
	elif [ $(id -u) -eq 0 ]; then
		_hoid_task_path__cfgs=/etc/profile
	else
		cd "$HOME"
		
		# see example: https://github.com/pyenv/pyenv?tab=readme-ov-file#bash
		for _hoid_task_path__cfg in .bash_profile .bash_login; do
			if [ -f "$_hoid_task_path__cfg" ]; then
				_hoid_task_path__cfgs="$_hoid_task_path__cfgs $_hoid_task_path__cfg"
			fi
		done
		unset _hoid_task_path__cfg

		if [ -z "$_hoid_task_path__cfg" ]; then
			touch -a ".profile"
		fi
		if [ -f .profle ]; then
			_hoid_task_path__cfgs="$_hoid_task_path__cfgs .profile"
		fi

		touch -a .bashrc
		_hoid_task_path__cfgs="$_hoid_task_path__cfgs .bashrc"
	fi

	# lineinfile arguments
	hoid_task_lineinfile__search_type=fixed
	hoid_task_lineinfile__line='test -d '"$1"' && printf %s "$PATH" | grep -F -q '"$1"' || PATH="$PATH:'"$1"'"'


	# apply configuration
	for hoid_task_lineinfile__file in $_hoid_task_path__cfgs; do
		hoid_task_lineinfile
	done
	unset _hoid_task_path__cfgs
}
EOF
)

hoid_task_path_function="$hoid_task_lineinfile_function

$hoid_task_path_function
"


hoid_task_path() {
	if ! bobshell_isset_1 "$@"; then
		bobshell_die "hoid_task_path: one argument expected"
	fi

	if bobshell_isset_2 "$@"; then
		bobshell_die "hoid_task_path: exactly one argument expected"
	fi

	if bobshell_contains "$1" "'"; then
		bobshell_die "hoid_task_path: single quotes not supported" # todo
	fi

	# shellcheck disable=SC2016
	hoid --env "hoid_task_path__value=$1" --env hoid_task_path_configs="${hoid_task_path_configs:-}" script '
'"$hoid_task_path_function"'
hoid_task_path "$hoid_task_path__value"'
}