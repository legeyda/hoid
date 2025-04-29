


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/set.sh
shelduck import ../find.sh
shelduck import ../util.sh


bobshell_event_listen hoid_event_cli_usage "printf -- '    -p --profile   Profile
'"

bobshell_event_listen hoid_event_cli_start unset hoid_alt_profile

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-p|--profile)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_alt_profile="$2"
				shift 2
				;; '


hoid_mod_profile_alt_diff() {
	if bobshell_isset hoid_alt_profile; then
		if ! bobshell_isset hoid_profile; then
			bobshell_result_set false
			return
		fi
		if [ "$hoid_alt_profile" != "$hoid_profile" ]; then
			bobshell_result_set false
			return
		fi
	fi
	bobshell_result_set true
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_alt_diff_event '
hoid_mod_profile_alt_diff
if ! bobshell_result_check; then
	return
fi'


bobshell_event_listen hoid_alt_clear unset hoid_alt_profile



hoid_mod_profile_state_dump() {
	hoid_util_state_dump hoid_profile
}
bobshell_event_listen hoid_event_state_dump hoid_mod_profile_state_dump



hoid_mod_profile_init_event_listener() {
	if bobshell_isset hoid_alt_profile; then
		bobshell_event_var_set hoid_profile "$hoid_alt_profile"
	elif bobshell_isset hoid_profile; then
		true
	elif bobshell_isset HOID_PROFILE; then
		bobshell_event_var_set hoid_profile "$HOID_PROFILE"
	else
		bobshell_event_var_unset hoid_profile
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_profile_init_event_listener "$@"'



bobshell_event_var_listen hoid_profile hoid_mod_profile_var_event_listener 
hoid_mod_profile_var_event_listener() {
	if [ true = "${_hoid_mod_profile_var_event_listener__disabled:-false}" ]; then
		return
	fi
	if ! bobshell_isset hoid_profile; then
		return
	fi
	for _hoid_mod_profile_var_event_listener__item in $(hoid_find_all env.sh); do
		. "$_hoid_mod_profile_var_event_listener__item"
	done
	unset _hoid_mod_profile_var_event_listener__item
	
	_hoid_mod_profile_var_event_listener__disabled=true
	hoid_state_init
	unset _hoid_mod_profile_var_event_listener__disabled
}



bobshell_event_var_listen --before    hoid_profile hoid_buffer_flush 
