


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/event/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/event/var/set.sh
shelduck import ../util.sh


bobshell_event_listen hoid_event_cli_usage "printf -- '    -t --target    Target
'"

bobshell_event_listen hoid_event_cli_start unset hoid_alt_target

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-t|--target)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_alt_target="$2"
				shift 2
				;;'


hoid_mod_target_alt_diff() {
	if bobshell_isset hoid_alt_target; then
		if ! bobshell_isset hoid_target; then
			bobshell_result_set false
			return
		fi
		if [ "$hoid_alt_target" != "$hoid_target" ]; then
			bobshell_result_set false
			return
		fi
	fi
	bobshell_result_set true
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_alt_diff_event '
hoid_mod_target_alt_diff
if ! bobshell_result_check; then
	return
fi'


bobshell_event_listen hoid_alt_clear unset hoid_alt_target


# shellcheck disable=SC2016
bobshell_event_listen hoid_state_validate_event '
	if [ local != $hoid_driver ] && ! bobshell_isset hoid_target; then
		bobshell_result_set false "hoid is in invalid state: hoid_target is not set"
		return
	fi
'


hoid_mod_target_state_dump() {
	hoid_util_state_dump hoid_target
}
bobshell_event_listen hoid_event_state_dump hoid_mod_target_state_dump



hoid_mod_target_init_event_listener() {
	if bobshell_isset hoid_alt_target; then
		bobshell_event_var_set hoid_target "$hoid_alt_target"
	elif bobshell_isset hoid_target; then
		true
	elif bobshell_isset HOID_TARGET; then
		bobshell_event_var_set hoid_target "$HOID_TARGET"
	fi
	
	if bobshell_isset hoid_target && ! bobshell_isset hoid_profile; then
		bobshell_event_var_set hoid_profile "$hoid_target"
	fi

	if bobshell_isset hoid_profile && ! bobshell_isset hoid_target; then
		bobshell_event_var_set hoid_target "$hoid_profile"
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_target_init_event_listener "$@"'



bobshell_event_var_listen --before    hoid_target hoid_buffer_flush 


bobshell_event_var_listen --after hoid_target hoid_mod_driver_init