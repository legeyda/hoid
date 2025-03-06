


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh

hoid_mod_become_cli_usage() {
	printf -- '    -b --become true|false    use privilege escalation
'
printf -- '    -p --become-password PASSWD    sudo-password if privilege escalation requires escalation
'
}
bobshell_event_listen hoid_event_cli_usage hoid_mod_become_cli_usage

bobshell_event_listen hoid_event_cli_start unset hoid_cli_become hoid_cli_become_password

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-b|--become)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				bobshell_equals_any "$2" true false || bobshell_die "hoid: option $1: argument expected to be either true or false"
				hoid_cli_become="$2"
				shift 2
				;;
			(-p|--become-password)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_become_password="$2"
				shift 2
				;;'


hoid_mod_become_cli_diff() {
	if bobshell_isset hoid_cli_become; then
		if ! bobshell_isset hoid_become; then
			return 1
		fi
		if [ "$hoid_cli_become" != "$hoid_become" ]; then
			return 1
		fi
	fi
	if bobshell_isset hoid_cli_become_password; then
		if ! bobshell_isset hoid_become_password; then
			return 1
		fi
		if [ "$hoid_cli_become_password" != "$hoid_become_password" ]; then
			return 1
		fi
	fi
}
bobshell_event_listen hoid_event_cli_diff 'hoid_mod_become_cli_diff || return 1'


hoid_mod_become_state_default() {
	if bobshell_isset HOID_BECOME; then
		hoid_become="$HOID_BECOME"
	else
		hoid_become=false
	fi

	if bobshell_isset HOID_BECOME_PASSWORD; then
		hoid_become_password="$HOID_BECOME_PASSWORD"
	else
		unset hoid_become_password
	fi
}
bobshell_event_listen hoid_event_state_default hoid_mod_become_state_default


hoid_mod_become_state_dump() {
	if bobshell_isset hoid_become; then
		printf 'hoid_state_load_become=%s\n' "$hoid_become"
	else
		printf '%s\n' "unset hoid_state_load_become"
	fi
	if bobshell_isset hoid_become_password; then
		printf 'hoid_state_load_become_password=%s\n' "$hoid_become_password"
	else
		printf '%s\n' "unset hoid_state_load_become_password"
	fi
}
bobshell_event_listen hoid_event_state_dump hoid_mod_become_state_dump

hoid_mod_become_state_load() {
	if bobshell_isset hoid_state_load_become; then
		hoid_set_become "$hoid_state_load_become"
	else
		unset hoid_become
	fi
	if bobshell_isset "hoid_state_load_become_password"; then
		hoid_become_password=hoid_state_load_become_password
	else
		unset hoid_become_password
	fi
}
bobshell_event_listen hoid_event_state_load hoid_mod_become_state_load




hoid_mod_become_init() {
	if bobshell_isset hoid_cli_become; then
		hoid_set_become "$hoid_cli_become"
	elif [ -z "${hoid_become:-}" ]; then
		hoid_set_become false
	fi

	if bobshell_isset hoid_cli_become_password; then
		hoid_set_become_password "$hoid_cli_become_password"
	elif [ -z "${hoid_cli_become_password:-}" ]; then
		hoid_set_become_password
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_become_init "$@"'






hoid_set_become() {
	if bobshell_isset_1 "$@" && bobshell_isset hoid_become && [ "$hoid_become" = "$1" ]; then
		return
	fi
	hoid_buffer_flush

	if ! bobshell_isset_1 "$@"; then
		unset hoid_become
		return
	fi

	hoid_become="$1"
}

hoid_set_become_password() {
	if bobshell_isset_1 "$@" && bobshell_isset hoid_become_password && [ "$hoid_become_password" = "$1" ]; then
		return
	fi
	hoid_buffer_flush

	if ! bobshell_isset_1 "$@"; then
		unset hoid_become_password
		return
	fi

	hoid_become_password="$1"
}




hoid_mod_become_rewrite() {
	if [ "$hoid_become" != true ]; then
		return
	fi


	if bobshell_contains "$hoid_buffer" "'"; then
		hoid_buffer="set -eu; sudo sh -c 'set -eu; $hoid_buffer'"
	else
		bobshell_buffer_rewrite_random="$(bobshell_random)$(bobshell_random)$(bobshell_random)"
		hoid_buffer="set -eu;
script=\$(cat<""<EOF_$bobshell_buffer_rewrite_random
set -eu
$hoid_buffer
EOF_$bobshell_buffer_rewrite_random
)
sudo sh -c \"\$script\"
"
	fi
}
bobshell_event_listen hoid_event_buffer_rewrite hoid_mod_become_rewrite