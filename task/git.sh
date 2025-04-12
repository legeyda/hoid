
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/subcommand.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh
shelduck import ./install/docker.sh

hoid_task_git() {
	bobshell_subcommand hoid_task_git "$@"
}

hoid_task_git_clone() {
	_hoid_task_git_clone__command='git clone'
	if ! bobshell_isset_2 "$@"; then
		bobshell_die 'hoid_task_git_clone: usage: hoid git clone REPO DESTDIR (dir is mandatory)'
	fi
	while bobshell_isset_2 "$@"; do
		_hoid_task_git_clone__arg=$(bobshell_quote "$1")
		_hoid_task_git_clone__command="$_hoid_task_git_clone__command $_hoid_task_git_clone__arg"
		unset _hoid_task_git_clone__arg
		shift
	done

	_hoid_task_git_clone__local_dir=$(mktemp -d)
	_hoid_task_git_clone__command="$_hoid_task_git_clone__command '$_hoid_task_git_clone__local_dir'"
	eval "$_hoid_task_git_clone__command"
	unset _hoid_task_git_clone__command

	hoid copy "$_hoid_task_git_clone__local_dir" "$1"
}


