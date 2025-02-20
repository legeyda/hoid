


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh


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



hoid_set_become() {
	if bobshell_isset hoid_become && [ "$hoid_become" = "$1" ]; then
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
	if bobshell_isset hoid_become_password && [ "$hoid_become_password" = "$1" ]; then
		return
	fi
	hoid_buffer_flush

	if ! bobshell_isset_1 "$@"; then
		unset hoid_become_password
		return
	fi

	hoid_become_password="$1"
}