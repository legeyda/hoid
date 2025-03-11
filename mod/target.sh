


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/set.sh

bobshell_event_listen hoid_event_cli_usage "printf -- '    -t --target    Target
    -d --driver    Driver
'"

bobshell_event_listen hoid_event_cli_start unset hoid_cli_target
bobshell_event_listen hoid_event_cli_start unset hoid_cli_driver
bobshell_event_listen hoid_event_cli_start unset hoid_cli_profile

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-t|--target)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_target="$2"
				shift 2
				;;
			(-d|--driver)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_driver="$2"
				shift 2
				;;
			(-d|--prifile)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_cli_profile="$2"
				shift 2
				;; '


hoid_mod_target_cli_diff() {
	if bobshell_isset hoid_cli_target; then
		if ! bobshell_isset hoid_target; then
			return 1
		fi
		if [ "$hoid_cli_target" != "$hoid_target" ]; then
			return 1
		fi
	fi
	if bobshell_isset hoid_cli_driver; then
		if ! bobshell_isset hoid_driver; then
			return 1
		fi
		if [ "$hoid_cli_driver" != "$hoid_driver" ]; then
			return 1
		fi
	fi
	if bobshell_isset hoid_cli_profile; then
		if ! bobshell_isset hoid_profile; then
			return 1
		fi
		if [ "$hoid_cli_profile" != "$hoid_profile" ]; then
			return 1
		fi
	fi
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_diff 'hoid_mod_target_cli_diff || return 1'




hoid_mod_target_state_default() {
	if bobshell_isset HOID_TARGET; then
		hoid_mod_target_refresh_target=$HOID_TARGET
	else
		unset hoid_mod_target_refresh_target
	fi
	hoid_mod_target_refresh_driver=${HOID_DRIVER:-ssh}
	if bobshell_isset HOID_PROFILE; then
		hoid_mod_target_refresh_profile=$HOID_PROFILE
	else
		unset hoid_mod_target_refresh_profile
	fi
	hoid_mod_target_refresh
}
bobshell_event_listen hoid_event_state_default hoid_mod_target_state_default


hoid_mod_target_state_dump() {
	if bobshell_isset hoid_target; then
		printf 'hoid_state_load_target=%s\n' "$hoid_target"
	else
		printf '%s\n' "unset hoid_state_load_target"
	fi
	if bobshell_isset hoid_driver; then
		printf 'hoid_state_load_driver=%s\n' "$hoid_driver"
	else
		printf '%s\n' "unset hoid_state_load_driver"
	fi
	if bobshell_isset hoid_profile; then
		printf 'hoid_state_load_profile=%s\n' "$hoid_profile"
	else
		printf '%s\n' "unset hoid_state_load_profile"
	fi
}
bobshell_event_listen hoid_event_state_dump hoid_mod_target_state_dump

hoid_mod_target_state_load() {
	if bobshell_isset hoid_state_load_target; then
		hoid_mod_target_refresh_target=$hoid_state_load_target
	else
		unset hoid_target
	fi
	if bobshell_isset hoid_state_load_driver; then
		hoid_mod_target_refresh_driver=$hoid_state_load_driver
	else
		unset hoid_driver
	fi
	if bobshell_isset hoid_state_load_profile; then
		hoid_mod_target_refresh_profile=$hoid_state_load_profile
	else
		unset hoid_profile
	fi
	hoid_mod_target_refresh
}
bobshell_event_listen hoid_event_state_load hoid_mod_target_state_load



hoid_mod_target_init() {
	if bobshell_isset hoid_cli_target; then
		hoid_mod_target_refresh_target=$hoid_cli_target
	elif [ -z "${hoid_target:-}" ]; then
		hoid_mod_target_refresh_target=$HOID_TARGET
	fi
	if bobshell_isset hoid_cli_driver; then
		hoid_mod_target_refresh_driver=$hoid_cli_driver
	elif [ -z "${hoid_driver:-}" ]; then
		hoid_mod_target_refresh_driver=$HOID_DRIVER
	fi
	if bobshell_isset hoid_cli_profile; then
		hoid_mod_target_refresh_profile=$hoid_cli_profile
	elif [ -z "${hoid_profile:-}" ]; then
		hoid_mod_target_refresh_profile=$HOID_PROFILE
	fi
	hoid_mod_target_refresh
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_target_init "$@"'



# txt: 
# env: HOID_TARGET
# shellcheck disable=SC2120
hoid_mod_target_refresh() {
	if bobshell_isset hoid_target && [ "$hoid_target" = "$hoid_mod_target_refresh_target" ]; then
		if bobshell_isset hoid_driver && [ "$hoid_driver" = "$hoid_mod_target_refresh_driver" ]; then
			if bobshell_isset hoid_profile && [ "$hoid_profile" = "$hoid_mod_target_refresh_profile" ]; then
				return
			fi
		fi
	fi

	hoid_buffer_flush

	bobshell_event_var_set hoid_profile "${hoid_mod_target_refresh_profile:-hoid_mod_target_refresh_target}"




	_hoid_mod_target_refresh__old_target=${HOID_TARGET:-}
	_hoid_mod_target_refresh__old_driver=${HOID_DRIVER:-}

	# possibly updates HOID_TARGET & HOID_DRIVER 
	hoid_load_profile "$hoid_profile"

	if bobshell_isset hoid_mod_target_refresh_target; then
		bobshell_event_var_set hoid_target "$hoid_mod_target_refresh_target"
	elif bobshell_isset HOID_TARGET && [ "$_hoid_mod_target_refresh__old_target" != "$HOID_TARGET" ]; then
		bobshell_event_var_set hoid_target "$HOID_TARGET"
	else
		bobshell_die "target not set"
	fi

	if bobshell_isset hoid_mod_target_refresh_driver; then
		hoid_driver=$hoid_mod_target_refresh_driver	
	elif bobshell_isset HOID_DRIVER && [ "$_hoid_mod_target_refresh__old_driver" != "$HOID_DRIVER" ]; then
		hoid_driver=$HOID_DRIVER
	else
		hoid_driver=ssh
	fi





	unset _hoid_mod_target_refresh__old_driver


	"hoid_driver_${hoid_driver}_init"

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

