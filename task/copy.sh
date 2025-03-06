
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/locator/resolve.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/locator/is_file.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/resource/copy.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/random.sh

hoid_dir_is_not_empty() {
	_hoid_dir_is_empty=$(ls -A "$1")
	set -- "$_hoid_dir_is_empty"
	unset _hoid_dir_is_empty
	test -n "$1"
}

hoid_mktemp_dir() {
	while true; do
		_hoid_mktemp_dir=$(bobshell_random)
		_hoid_mktemp_dir="$HOME/.cache/hoid/temp/$_hoid_mktemp_dir"
		if ! [ -e "$_hoid_mktemp_dir" ]; then
			break
		fi
	done
	mkdir -p "$_hoid_mktemp_dir"
	printf %s "$_hoid_mktemp_dir"
	unset _hoid_mktemp_dir
}

hoid_task_copy() {
	_hoid_task_copy__src=$(bobshell_locator_resolve "$1")

	if bobshell_locator_is_file "$_hoid_task_copy__src" _hoid_task_copy__src_file; then
		if [ -d "$_hoid_task_copy__src_file" ]; then
			hoid command mkdir -p "$2"
			if hoid_dir_is_not_empty "$_hoid_task_copy__src_file"; then
				_hoid_task_copy__temp=$(hoid_mktemp_dir)
				tar --create --gzip --file - --directory "$1" . > "$_hoid_task_copy__temp/archive.tar.gz"
				hoid command tar --extract --ungzip --file - --directory "$2"
				hoid flush --input "file:$_hoid_task_copy__temp/archive.tar.gz"
				rm -rf "$_hoid_task_copy__temp"
				unset _hoid_task_copy__temp
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
	hoid script "cat > $_hoid_task_copy__dest"
	unset _hoid_task_copy__dest

	hoid flush --input "$_hoid_task_copy__src"
	unset _hoid_task_copy__src
}