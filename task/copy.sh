
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/locator/resolve.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/locator/is_file.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/locator/is_readable.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/resource/copy.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/random.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/template.sh

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
	unset _hoid_task_copy__mapper
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-m|--mustache)
				_hoid_task_copy__mapper="bobshell_mustache"
				shift
				;;
			(-i|--interpolate)
				_hoid_task_copy__mapper="bobshell_interpolate"
				shift
				;;
			(-*)
				bobshell_die "hoid_task_copy: unrecognized option $1"
				;;
			(*)
				break
				;;
		esac
	done


	_hoid_task_copy__src=$(bobshell_locator_resolve "$1")

	if bobshell_locator_is_file "$_hoid_task_copy__src" _hoid_task_copy__src_file; then
		if [ -d "$_hoid_task_copy__src_file" ]; then
			hoid command mkdir -p "$2"
			if hoid_dir_is_not_empty "$_hoid_task_copy__src_file"; then
				_hoid_task_copy__temp=$(hoid_mktemp_dir)
				if bobshell_isset _hoid_task_copy__mapper; then
					# todo reset; find . -wholename './.*' -prune -o  -type d -printf "mkdir -p '%p'\n" -o -printf "hoid_task_map 'file://%p'\n"
					bobshell_die 'not implemented'
				else
					tar --create --gzip --file - --directory "$1" . > "$_hoid_task_copy__temp/archive.tar.gz"
					hoid command tar --extract --ungzip --file - --directory "$2"
					hoid flush --input "file:$_hoid_task_copy__temp/archive.tar.gz"
				fi
				rm -rf "$_hoid_task_copy__temp"
				unset _hoid_task_copy__temp
			fi
			unset _hoid_task_copy__src_file _hoid_task_copy__mapper
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

	if bobshell_isset _hoid_task_copy__mapper; then
		_hoid_task_copy__temp=$(hoid_mktemp_dir)
		"$_hoid_task_copy__mapper" "$_hoid_task_copy__src" "file://$_hoid_task_copy__temp/result"
		hoid flush --input "file:$_hoid_task_copy__temp/result"		
		rm -rf "$_hoid_task_copy__temp"
		unset _hoid_task_copy__temp
	else
		hoid flush --input "$_hoid_task_copy__src"
	fi
	unset _hoid_task_copy__src _hoid_task_copy__mapper
}

hoid_task_copy_map() {
	if bobshell_isset _hoid_task_copy__mapper; then
		_hoid_task_copy_map__temp=$(hoid_mktemp_dir)
		"$_hoid_task_copy__mapper" "$1" "$2"
		hoid flush --input "file://$_hoid_task_copy_map__temp/result"		
		rm -rf "$_hoid_task_copy_map__temp"
		unset _hoid_task_copy_map__temp
	else
		bobshell_resource_copy "$1" "$2"
	fi
}