


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/buffer/config.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/buffer/printf.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/unset.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/mimic.sh

bobshell_event_listen hoid_event_cli_usage "printf -- '    --chdir    Change into this directory before running remote commands
'"

bobshell_event_listen hoid_event_cli_start unset hoid_alt_chdir

# shellcheck disable=SC2016
bobshell_event_listen hoid_event_cli_options '
			(--chdir)
				bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected"
				hoid_alt_chdir="$2"
				shift 2
				;; '


hoid_mod_chdir_alt_diff() {
	if bobshell_isset hoid_alt_chdir; then
		if ! bobshell_isset hoid_chdir; then
			bobshell_result_set false
			return
		fi
		if [ "$hoid_alt_chdir" != "$hoid_target" ]; then
			bobshell_result_set false
			return
		fi
	fi
	bobshell_result_set true
}
# shellcheck disable=SC2016
bobshell_event_listen hoid_alt_diff_event '
hoid_mod_chdir_alt_diff
if ! bobshell_result_check; then
	return
fi'




hoid_mod_chdir_state_default() {
	if bobshell_isset HOID_CHDIR; then
		hoid_chdir=$HOID_CHDIR
	else
		unset hoid_chdir
	fi
}
bobshell_event_listen hoid_event_state_default hoid_mod_chdir_state_default





hoid_mod_chdir_state_dump() {
	if bobshell_isset hoid_chdir; then
		printf "bobshell_event_var_set hoid_chdir '%s'\n" "$hoid_chdir"
	else
		printf 'bobshell_event_var_unset hoid_chdir' 
	fi
}
bobshell_event_listen hoid_event_state_dump hoid_mod_chdir_state_dump




hoid_mod_chdir_init() {
	bobshell_event_var_mimic hoid_chdir hoid_alt_chdir
	unset hoid_alt_chdir
}
bobshell_event_listen hoid_event_state_init 'hoid_mod_chdir_init "$@"'





hoid_mod_chdir_rewrite_event_listener() {
	_hoid_mod_chdir_rewrite_event_listener=
	bobshell_buffer_config var:_hoid_mod_chdir_rewrite_event_listener
	bobshell_buffer_printf '\n# hoid_mod_chdir_rewrite_event_listener\n'
	bobshell_buffer_printf 'hoid_mod_chdir_init_dir=$(pwd)\n\n'
	hoid_buffer="$_hoid_mod_chdir_rewrite_event_listener$hoid_buffer"
	unset _hoid_mod_chdir_rewrite_event_listener
}
bobshell_event_listen hoid_event_buffer_rewrite hoid_mod_chdir_rewrite_event_listener




hoid_mod_chdir_script_start_listener() {
	hoid_buffer_printf '\n# hoid_mod_chdir_script_start_listener\n'
	if bobshell_isset hoid_chdir; then
		_hoid_mod_chdir_script_start_listener=$(bobshell_quote "$hoid_chdir")
		hoid_buffer_printf "mkdir %s\ncd %s\n\n" "$_hoid_mod_chdir_script_start_listener" "$_hoid_mod_chdir_script_start_listener"
		unset _hoid_mod_chdir_script_start_listener
	else
		hoid_buffer_printf 'cd "$hoid_mod_chdir_init_dir"\n\n'
	fi
}
bobshell_event_listen hoid_script_start_event 'hoid_mod_chdir_script_start_listener "$@"'






