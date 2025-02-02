




hoid_state_init() {
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

	if bobshell_isset hoid_cli_become; then
		hoid_set_become "$hoid_cli_become"
	elif [ -z "${hoid_become:-}" ]; then
		hoid_set_become false
	fi
}

hoid_state_valid() {
	if  [ -n "${hoid_target:-}" ] ; then
		return 0
	fi
	if  [ -n "${hoid_become:-}" ] ; then
		return 0
	fi
}

hoid_cli_differ() {
	if bobshell_isset hoid_cli_target && [ "$hoid_cli_target" != "${hoid_target:-}" ] ; then
		return 0
	fi
	if bobshell_isset hoid_cli_become && [ "$hoid_cli_become" != "${hoid_become:-}" ] ; then
		return 0
	fi
	return 1
}

# fun: hoid_state_push
hoid_state_push() {
	bobshell_stack_push hoid_stack_target "${hoid_target:-}"
	bobshell_stack_push hoid_stack_become "${hoid_become:-}"
}

# fun: hoid_state_pop
hoid_state_pop() {
	hoid_state_pop_size=$(bobshell_stack_size hoid_stack_target)
	if [ "$hoid_state_pop_size" = 0 ]; then
		bobshell_die 'invalid state stack'
	fi

	hoid_state_pop_size=$(bobshell_stack_size hoid_stack_become)
	if [ "$hoid_state_pop_size" = 0 ]; then
		bobshell_die 'invalid state stack'
	fi
	unset hoid_state_pop_size
	
	bobshell_stack_pop hoid_stack_target hoid_state_pop_target
	if [ -n "$hoid_state_pop_target" ]; then
		hoid_set_target "${hoid_state_pop_target:-}"
	else
		hoid_set_target
	fi
	unset hoid_state_pop_target

	bobshell_stack_pop hoid_stack_become hoid_state_pop_become
	if [ -n "${hoid_state_pop_become:-}" ]; then
		hoid_set_become "$hoid_state_pop_become"
	else
		hoid_set_become
	fi
	unset hoid_state_pop_become
}