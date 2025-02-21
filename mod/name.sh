

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh

hoid_mod_name_cli_usage() {
	printf -- '    -n --name    Task name
'
}
bobshell_event_listen hoid_event_cli_usage hoid_mod_name_cli_usage

bobshell_event_listen hoid_event_cli_start unset hoid_cli_name

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-n|--name)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				shift 2
				;;'

# bobshell_event_listen hoid_event_cli_diff '
# 	if ! bobshell_eqvar hoid_cli_name hoid_name; then
# 		return 1
# 	fi
# '
