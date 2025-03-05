
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/locator/resolve.sh

hoid_dir_is_not_empty() {
	_hoid_dir_is_empty=$(ls -A "$1")
	set -- "$_hoid_dir_is_empty"
	unset _hoid_dir_is_empty
	test -n "$1"
}

hoid_task_copy() {
	_hoid_task_copy__src=$(bobshell_locator_resolve "$1")

	if bobshell_locator_is_file "$_hoid_task_copy__src" _hoid_task_copy__src_file; then
		if [ -d "$_hoid_task_copy__src_file" ]; then
			hoid command mkdir -p "$2"
			if hoid_dir_is_not_empty "$_hoid_task_copy__src_file"; then
				hoid flush
				_hoid_task_copy__dest=$(bobshell_quote "$2")
				tar --create --gzip --file - --directory "$1" . | hoid_driver_write "tar --extract --ungzip --file - --directory $_hoid_task_copy__dest"
				unset _hoid_task_copy__dest
			fi
			unset _hoid_task_copy__src_file
			return
		fi
		unset _hoid_task_copy__src_file
	fi

	if ! bobshell_locator_is_readable "$_hoid_task_copy__src"; then
		bobshell_die "locator not readable: $1"
	fi


	_hoid_task_copy__dest_dir=$(dirname "$2")
	hoid command mkdir -p "$_hoid_task_copy__dest_dir"
	unset _hoid_task_copy__dest_dir

	_hoid_task_copy__dest=$(bobshell_quote "$2")
	hoid flush
	bobshell_copy "$_hoid_task_copy__src" stdout: | hoid_driver_write "cat > $_hoid_task_copy__dest"
	unset _hoid_task_copy__dest

	unset _hoid_task_copy__src
}