


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh

shelduck import ../util.sh

hoid_mod_become_cli_usage() {
	printf -- '    -b --become true|false    use privilege escalation
'
	printf -- '    -p --become-password PASSWD    sudo-password if privilege escalation requires escalation
'
}
bobshell_event_listen hoid_event_cli_usage hoid_mod_become_cli_usage

bobshell_event_listen hoid_event_cli_start unset hoid_alt_become hoid_alt_become_password

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-b|--become)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				bobshell_equals_any "$2" true false || bobshell_die "hoid: option $1: argument expected to be either true or false"
				hoid_alt_become="$2"
				shift 2
				;;
			(--become-password)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_alt_become_password="$2"
				shift 2
				;;'


hoid_mod_become_alt_diff() {
	if bobshell_isset hoid_alt_become; then
		if ! bobshell_isset hoid_become; then
			bobshell_result_set false
			return
		fi
		if [ "$hoid_alt_become" != "$hoid_become" ]; then
			bobshell_result_set false
			return
		fi
	fi
	if bobshell_isset hoid_alt_become_password; then
		if ! bobshell_isset hoid_become_password; then
			bobshell_result_set false
			return
		fi
		if [ "$hoid_alt_become_password" != "$hoid_become_password" ]; then
			bobshell_result_set false
			return
		fi
	fi
	bobshell_result_set true
}
bobshell_event_listen hoid_alt_diff_event '
hoid_mod_become_alt_diff
if ! bobshell_result_check; then
	return
fi'

bobshell_event_listen hoid_alt_clear unset hoid_alt_become hoid_alt_become_password


bobshell_event_var_listen hoid_become hoid_buffer_flush
bobshell_event_var_listen hoid_become_password hoid_buffer_flush




hoid_mod_become_state_dump() {
	hoid_util_state_dump hoid_become hoid_become_password
}
bobshell_event_listen hoid_event_state_dump hoid_mod_become_state_dump



hoid_mod_become_init() {
	
	if bobshell_isset hoid_alt_become; then
		bobshell_event_var_set hoid_become "$hoid_alt_become"
		unset hoid_alt_become
	elif bobshell_isset hoid_become; then
		true
	elif bobshell_isset HOID_BECOME; then
		bobshell_event_var_set hoid_become "$HOID_BECOME"
	else
		bobshell_event_var_set hoid_become false
	fi
	

	if bobshell_isset hoid_alt_become_password; then
		bobshell_event_var_set hoid_become_password "$hoid_alt_become_password"
		unset hoid_alt_become_password
	elif bobshell_isset hoid_become_password; then
		true
	elif bobshell_isset HOID_BECOME_PASSWORD; then
		bobshell_event_var_set hoid_become_password "$HOID_BECOME_PASSWORD"
	else
		bobshell_event_var_unset hoid_become_password
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_become_init "$@"'




bobshell_event_var_listen --before  hoid_become hoid_buffer_flush
bobshell_event_var_listen --before  hoid_become_password hoid_buffer_flush



hoid_mod_become_rewrite() {
	if [ "$hoid_become" != true ]; then
		return
	fi


	if bobshell_contains "$hoid_buffer" "'"; then
		bobshell_buffer_rewrite_random="$(bobshell_random)$(bobshell_random)$(bobshell_random)"
		hoid_buffer="set -eu;
script=\$(cat<""<\EOF_$bobshell_buffer_rewrite_random
set -eu
$hoid_buffer
EOF_$bobshell_buffer_rewrite_random
)
sudo sh -c \"\$script\"
"		
	else
		hoid_buffer="set -eu; sudo sh -c 'set -eu; $hoid_buffer'"
	fi
}
bobshell_event_listen hoid_event_buffer_rewrite hoid_mod_become_rewrite



