


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh


# txt: 
# env: hoid_target_driver
#      hoid_target_address
hoid_init() {
	unset hoid_target hoid_target_driver hoid_target_address

	if bobshell_isset_1 "$@"; then
		# shellcheck disable=SC2015
		bobshell_isset_2 "$@" && bobshell_die "hoid init: unexpected argument: $2" || true
		hoid_target="$1"
	elif bobshell_isset HOID_TARGET; then
		hoid_target="$HOID_TARGET"
	fi

	if bobshell_isset hoid_target && ! bobshell_split_first "$hoid_target" : hoid_target_driver hoid_target_address; then
		hoid_target_driver=ssh
		hoid_target_address="$hoid_target"
	fi

	hoid_copy_without_conflict

	if bobshell_isset hoid_target_address; then
		hoid_load_profile "$hoid_target_address"
		hoid_copy_without_conflict
	fi

	
	if ! bobshell_isset hoid_target_driver; then
		if bobshell_isset hoid_target_address; then
			hoid_target_driver=ssh
		else
			hoid_target_driver=local
		fi
	fi
	

	if ! bobshell_isset hoid_target_address; then
		if [ local != "$hoid_target_driver" ]; then
			bobshell_die 'address not set'
		fi
	fi

	if [ -z "$hoid_target_driver" ]; then
		bobshell_die "empty driver"
	fi

	hoid_driver_${hoid_target_driver}_init

}

hoid_copy_without_conflict() {
	hoid_copy_var_without_conflict HOID_TARGET_DRIVER  hoid_target_driver  || bobshell_die 'ambigous value for driver'
	hoid_copy_var_without_conflict HOID_TARGET_ADDRESS hoid_target_address || bobshell_die 'ambigous value for address'
}

hoid_copy_var_without_conflict() {
	if bobshell_isset "$1"; then
		if ! bobshell_isset "$2"; then
			bobshell_putvar "$2" "$1"
		else
			hoid_copy_var_without_conflict_1=$(bobshell_getvar "$1")
			hoid_copy_var_without_conflict_2=$(bobshell_getvar "$2")
			if [ "$hoid_copy_var_without_conflict_1" != "$hoid_copy_var_without_conflict_2" ]; then
				return 1
			fi
		fi
	fi
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