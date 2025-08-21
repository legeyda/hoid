
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/misc/subcommand.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/url.sh
shelduck import ./install/docker.sh

hoid_task_git() {
	bobshell_subcommand hoid_task_git "$@"
}

hoid_task_git_clone() {
	if ! bobshell_isset_1 "$@"; then
		bobshell_die 'hoid_task_git_clone: usage: hoid git clone REPO DESTDIR (dir is mandatory)'
	fi
	_hoid_task_git_clone__command=
	while bobshell_isset_2 "$@"; do
		_hoid_task_git_clone__arg=$(bobshell_quote "$1")
		_hoid_task_git_clone__command="$_hoid_task_git_clone__command $_hoid_task_git_clone__arg"
		unset _hoid_task_git_clone__arg
		shift
	done

	_hoid_task_git_clone__temp_dir=$(mktemp -d)
	if [ -n "$_hoid_task_git_clone__command" ] && (cd "$_hoid_task_git_clone__temp_dir" && eval "git clone $_hoid_task_git_clone__command"); then
		# the last argument is directory
		unset _hoid_task_git_clone__command

		_hoid_task_git_clone__src=$(ls "$_hoid_task_git_clone__temp_dir")
		_hoid_task_git_clone__src="$_hoid_task_git_clone__temp_dir/$_hoid_task_git_clone__src"
		_hoid_task_git_clone__dest=$1
	else
		# the last argument is not directory
		_hoid_task_git_clone__arg=$(bobshell_quote "$1")
		(cd "$_hoid_task_git_clone__temp_dir" && eval "git clone $_hoid_task_git_clone__command $_hoid_task_git_clone__arg")
		unset _hoid_task_git_clone__arg _hoid_task_git_clone__command
		
		_hoid_task_git_clone__dest=$(ls "$_hoid_task_git_clone__temp_dir")
		_hoid_task_git_clone__src="$_hoid_task_git_clone__temp_dir/$_hoid_task_git_clone__dest"
	fi
	hoid copy "$_hoid_task_git_clone__src" "$_hoid_task_git_clone__dest"
	unset _hoid_task_git_clone__src _hoid_task_git_clone__dest
	rm -rf "$_hoid_task_git_clone__temp_dir"
	unset _hoid_task_git_clone__temp_dir
}


