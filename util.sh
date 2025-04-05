
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/unset.sh




hoid_util_state_dump() {
	while bobshell_isset_1 "$@"; do
		if bobshell_isset "$1"; then
			_hoid_util_state_dump__value=$(bobshell_getvar "$1")
			printf "bobshell_event_var_set '%s' '%s'\n" "$1" "$_hoid_util_state_dump__value"
			unset _hoid_util_state_dump__value
		else
			printf 'bobshell_event_var_unset %s' "$1"
		fi
		shift
	done
}



hoid_util_select() {
	while bobshell_isset "$@"; do
		bobshell_resource_copy "$1" var:_hoid_util_select
		if [ -z "$_hoid_util_select" ]; then
			continue
		fi
		bobshell_result_set true "$_hoid_util_select"
		return
	done
	bobshell_result_set false
}