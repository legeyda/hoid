

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh



hoid_mod_name_setup_event_lisener() {
	if bobshell_isset HOID_NAME; then
		hoid_name="$HOID_NAME"
	else
		unset hoid_name
	fi
}
bobshell_event_listen hoid_setup_event hoid_mod_name_setup_event_lisener





hoid_mod_name_cli_usage() {
	printf -- '    -n --name    Task name
'
}
bobshell_event_listen hoid_event_cli_usage hoid_mod_name_cli_usage

bobshell_event_listen hoid_event_cli_start unset hoid_alt_name

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-n|--name)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_alt_name="$2"
				shift 2
				;;'

bobshell_event_listen hoid_alt_clear unset hoid_name
# bobshell_event_listen hoid_alt_diff_event '
# 	if ! bobshell_eqvarhoid_alt_name hoid_name; then
# 		return 1
# 	fi
# '
