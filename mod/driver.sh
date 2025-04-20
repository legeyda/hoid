


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/set.sh
shelduck import ../util.sh


bobshell_event_listen hoid_event_cli_usage "printf -- '    -d --driver    Driver
'"

bobshell_event_listen hoid_event_cli_start unset hoid_alt_driver

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-d|--driver)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_alt_driver="$2"
				shift 2
				;; '



# # todo
# bobshel_mod_driver_example() {
# 	while bobshell_isset "$@"; do
# 		bobshell_result_set false
# 		bosbhell_event_fire hoid_event_cli_opts
# 		if bobshell_result_check _x_shift; then
# 			shift "$_x_shift"
# 			unset _x_shift
# 		elif bobshell_starts_with "$1" -; then
# 			bobshell_die "unexpeced option $1"
# 		else
# 			break;
# 		fi
# 	done

# }


# bobshell_event_listen hoid_event_cli_opts '
# 	if [ "${1:-}" == --driver ]; then
# 		hoid_driver="$2"
# 		bobshell_result_set true 2
# 		return
# 	fi
# '




hoid_mod_driver_alt_diff() {
	if bobshell_isset hoid_alt_driver; then
		if ! bobshell_isset hoid_driver; then
			bobshell_result_set false
			return
		fi
		if [ "$hoid_alt_driver" != "$hoid_driver" ]; then
			bobshell_result_set false
			return
		fi
	fi
	bobshell_result_set true
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_alt_diff_event '
hoid_mod_driver_alt_diff
if ! bobshell_result_check; then
	return
fi'


bobshell_event_listen hoid_alt_clear unset hoid_alt_driver



hoid_mod_driver_state_dump() {
	hoid_util_state_dump hoid_driver
}
bobshell_event_listen hoid_event_state_dump hoid_mod_driver_state_dump



hoid_mod_driver_init() {
	if ! bobshell_isset hoid_target; then
		# without target, driver cannot be configured, so skip driver configuration
		bobshell_event_var_unset hoid_driver
		return
	fi
	if bobshell_isset hoid_alt_driver; then
		bobshell_event_var_set hoid_driver "$hoid_alt_driver"
	elif bobshell_isset hoid_driver; then
		true
	elif bobshell_isset HOID_DRIVER; then
		bobshell_event_var_set "$HOID_DRIVER"
	else
		bobshell_event_var_set hoid_driver ssh
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_driver_init "$@"'







hoid_mod_driver_var_event_listener() {
	if bobshell_isset hoid_driver && bobshell_isset hoid_target; then
		"hoid_driver_${hoid_driver}_init"
	fi
}
bobshell_event_var_listen hoid_driver hoid_mod_driver_var_event_listener 




bobshell_event_var_listen --before    hoid_driver hoid_buffer_flush 