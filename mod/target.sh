


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh

bobshell_event_listen hoid_event_cli_usage "printf -- '    -t --target    Target
'"

bobshell_event_listen hoid_event_cli_start unset hoid_cli_target

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-t|--target)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_target="$2"
				shift 2
				;;'


bobshell_event_listen hoid_event_cli_diff '
	if ! bobshell_eqvar hoid_cli_target hoid_target; then
		return 1
	fi'




hoid_mod_target_state_default() {
	if bobshell_isset HOID_TARGET; then
		hoid_target="$HOID_TARGET"
	else
		unset hoid_target
	fi
}
bobshell_event_listen hoid_event_state_default hoid_mod_target_state_default


hoid_mod_target_state_dump() {
	if bobshell_isset hoid_target; then
		printf 'hoid_state_load_target=%s\n' "$hoid_target"
	else
		printf '%s\n' "unset hoid_state_load_target"
	fi
}
bobshell_event_listen hoid_event_state_dump hoid_mod_target_state_dump

hoid_mod_target_state_load() {
	if bobshell_isset hoid_state_load_target; then
		hoid_set_target "$hoid_state_load_target"
	else
		unset hoid_target
	fi
}
bobshell_event_listen hoid_event_state_load hoid_mod_target_state_load

hoid_mod_target_init() {
	if bobshell_isset_1 "$@"; then
		if bobshell_isset hoid_cli_target && [ "$1" != "$hoid_cli_target" ] ; then
			bobshell_die 'hoid init: ambigous target'
		fi
		hoid_set_target "$1"
	elif bobshell_isset hoid_cli_target; then
		hoid_set_target "$hoid_cli_target"
	elif [ -z "${hoid_target:-}" ]; then
		hoid_set_target "$HOID_TARGET"
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_target_init "$@"'



# txt: 
# env: HOID_TARGET_DRIVER
#      HOID_TARGET_ADDRESS
# shellcheck disable=SC2120
hoid_set_target() {
	if bobshell_isset hoid_target && [ "$hoid_target" = "$1" ]; then
		return
	fi

	hoid_buffer_flush

	if ! bobshell_isset_1 "$@"; then
		unset hoid_target hoid_target_driver hoid_target_address
		return
	fi

	hoid_target="$1"

	# possibly updates HOID_TARGET_DRIVER, HOID_TARGET_ADDRESS
	hoid_load_profile "$hoid_target"

	if bobshell_split_first "$hoid_target" : hoid_parse_target_driver hoid_parse_target_driver; then
		if bobshell_isset HOID_TARGET_DRIVER && [ "$HOID_TARGET_DRIVER" != "$hoid_parse_target_driver" ]; then
			bobshell_die "hoid: ambigous driver config: $HOID_TARGET_DRIVER, $hoid_parse_target_driver"
		fi
		hoid_target_driver="$hoid_parse_target_driver"

		if bobshell_isset HOID_TARGET_ADDRESS && [ "$HOID_TARGET_ADDRESS" != "$hoid_parse_target_address" ]; then
			bobshell_die "hoid: ambigous address config: $HOID_TARGET_ADDRESS, $hoid_parse_target_address"
		fi
		hoid_target_address="$hoid_parse_target_address"
	else
		hoid_target_driver="${HOID_TARGET_DRIVER:-ssh}"
		hoid_target_address="${HOID_TARGET_ADDRESS:-$hoid_target}"
	fi

	if [ -z "$hoid_target_driver" ]; then
		bobshell_die "empty driver"
	fi

	"hoid_driver_${hoid_target_driver}_init" "$hoid_target_address"

}


hoid_load_profile() {
	hoid_profile="$1"
	: "${hoid_profile_parent_dir=${HOID_PROFILE_PARENT_DIR:-$HOME/.config/hoid/profile}}"
	: "${hoid_profile_dir=${HOID_PROFILE_DIR:-$hoid_profile_parent_dir/$hoid_profile}}"
	: "${hoid_env_file=${HOID_ENV_FILE:-$hoid_profile_dir/env.sh}}"

	if [ -f "$hoid_env_file" ]; then
		eval "$hoid_init_env_file"
	fi

}

