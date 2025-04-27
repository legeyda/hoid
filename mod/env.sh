


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/str/path/join.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/result/check.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/buffer/config.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/buffer/printf.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/unset.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/mimic.sh
shelduck import ../util.sh


bobshell_event_listen hoid_event_cli_usage "printf -- '    -e, --env    Change into this directory before running remote commands
'"

bobshell_event_listen hoid_event_cli_start unset hoid_alt_env

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(-e|--env)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				bobshell_mod_env_apply_arg "$2"
				shift 2
				;; '



bobshell_mod_env_apply_arg() {
	if ! bobshell_split_first "$1" = _bobshell_mod_env_apply_arg__key _bobshell_mod_env_apply_arg__value; then
		_bobshell_mod_env_apply_arg__key="$1"
		unset _bobshell_mod_env_apply_arg__value
	fi

	if ! bobshell_regex_match "$_bobshell_mod_env_apply_arg__key" '[A-Za-z_][A-Za-z_0-9]*'; then
		unset _bobshell_mod_env_apply_arg__key _bobshell_mod_env_apply_arg__value
		bobshell_result_set false 'key should be like posix variable'
		return
	fi
	
	if ! bobshell_isset _bobshell_mod_env_apply_arg__value; then
		bobshell_var_get "$_bobshell_mod_env_apply_arg__key"
		if ! bobshell_result_check _bobshell_mod_env_apply_arg__value; then
			unset _bobshell_mod_env_apply_arg__key _bobshell_mod_env_apply_arg__value
			bobshell_result_set false "variable $_bobshell_mod_env_apply_arg__key undefined"
		fi
	fi

	_bobshell_mod_env_apply_arg__value=$(bobshell_quote "$_bobshell_mod_env_apply_arg__value")
	_bobshell_mod_env_apply_arg__line="
	export $_bobshell_mod_env_apply_arg__key=$_bobshell_mod_env_apply_arg__value
"
	unset _bobshell_mod_env_apply_arg__key _bobshell_mod_env_apply_arg__value

	if bobshell_contains "${hoid_env:-}" "$_bobshell_mod_env_apply_arg__line"; then
		unset _bobshell_mod_env_apply_arg__line
		bobshell_result_set true
		return
	fi

	hoid_alt_env="${hoid_alt_env:-}$_bobshell_mod_env_apply_arg__line"
	unset _bobshell_mod_env_apply_arg__line
}


hoid_mod_env_alt_diff() {
	if bobshell_isset hoid_alt_env; then
		bobshell_result_set false
	else
		bobshell_result_set true
	fi
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_alt_diff_event '
hoid_mod_env_alt_diff
if ! bobshell_result_check; then
	return
fi'


bobshell_event_listen hoid_alt_clear unset hoid_alt_env





hoid_mod_env_state_dump() {
	hoid_util_state_dump hoid_env
}
bobshell_event_listen hoid_event_state_dump hoid_mod_env_state_dump




hoid_mod_env_init() {
	if ! bobshell_isset hoid_env; then
		if bobshell_isset HOID_ENV; then
			hoid_env="$HOID_ENV"
		fi
	elif bobshell_isset hoid_alt_env; then
		hoid_env="$hoid_env$hoid_alt_env"
	fi
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_env_init "$@"'





hoid_mod_env_script_start_listener() {
	if ! bobshell_isset hoid_env; then
		return
	fi
	hoid_buffer_printf '\n\n# hoid_mod_env_script_start_listener\n'
	hoid_buffer_printf '%s\n' "$hoid_env"
}
bobshell_event_listen hoid_script_start_event 'hoid_mod_env_script_start_listener "$@"'






