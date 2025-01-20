
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh

# hoid_build_string clear
# hoid_build_string command echo hello
# hoid_build_string shell echo hello

hoid_task_directory() {
	unset hoid_task_directory_path hoid_task_directory_mode

	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-m|--mode)
				hoid_task_directory_mode="$2"
				shift 2
				;;

			(-u|--owner)
				bobshell_die 'owner not implemented'
				;;

			(-g|--group)
				bobshell_die 'group not implemented'
				;;
					
			(*)
				hoid_task_directory_path="$1"
				if bobshell_isset_2 "$@"; then
					bobshell_die 'extra argument'
				fi
				set --
				break
		esac
	done

	if [ -z "$hoid_task_directory_path" ]; then
		bobshell_die 'path not set'
	fi

	mkdir -p "$hoid_task_directory_path"
	if bobshell_isset hoid_task_directory_mode; then
		chmod "$hoid_task_directory_mode" "$hoid_task_directory_path"
	fi
	unset hoid_task_directory_mode hoid_task_directory_path
}
