




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

	if bobshell_isset hoid_cli_become_password; then
		hoid_become_password="$hoid_cli_become_password"
	elif [ -z "${hoid_cli_become_password:-}" ]; then
		unset hoid_become_password
	fi

}


hoid_cli_differ() {
	if bobshell_isset hoid_cli_target && [ "$hoid_cli_target" != "${hoid_target:-}" ] ; then
		return 0
	fi
	if bobshell_isset hoid_cli_become && [ "$hoid_cli_become" != "${hoid_become:-}" ] ; then
		return 0
	fi
	if bobshell_isset hoid_cli_become_password && [ "$hoid_cli_become_password" != "${hoid_become_password:-}" ] ; then
		return 0
	fi
	return 1
}

# fun: hoid_state_push
hoid_state_push() {
	hoid_state_push_value=$(hoid_state_dump)
	bobshell_stack_push hoid_state_stack "$hoid_state_push_value"
	unset hoid_state_push_value
}

# fun: hoid_state_pop
hoid_state_pop() {
	hoid_state_pop_size=$(bobshell_stack_size hoid_state_stack)
	if [ "$hoid_state_pop_size" = 0 ]; then
		bobshell_die 'invalid state stack'
	fi
	unset hoid_state_pop_size

	bobshell_stack_pop hoid_state_stack hoid_state_pop_value
	hoid_state_load "$hoid_state_pop_value"
	unset hoid_state_pop_value
}


# fun: hoid_state_dump
hoid_state_dump() {
	hoid_state_dump_separator=
	for hoid_state_dump_name in target become become_password; do
		printf %s "$hoid_state_dump_separator"
		if bobshell_isset "hoid_$hoid_state_dump_name"; then
			printf 'hoid_state_load_%s=' "$hoid_state_dump_name"
			hoid_state_dump_value=$(bobshell_getvar "hoid_$hoid_state_dump_name")
			bobshell_quote "$hoid_state_dump_value"
			unset hoid_state_dump_value
		else
			printf 'unset %s' "hoid_state_load_$hoid_state_dump_name"
		fi
		hoid_state_dump_separator="; "
	done
	unset hoid_state_dump_separator
}

hoid_state_load() {
	eval "$1"
	for hoid_state_load_name in target become; do
		bobshell_optarg "hoid_state_load_$hoid_state_load_name" "hoid_set_$hoid_state_load_name"
	done
	# shellcheck disable=SC2043
	for hoid_state_load_name in become_password; do
		if bobshell_isset "hoid_state_load_$hoid_state_load_name"; then
			bobshell_copy "var:hoid_state_load_$hoid_state_load_name" "var:hoid_$hoid_state_load_name"
		else
			unset "hoid_$hoid_state_load_name"
		fi
	done
}


# todo move to bobshell
# fun: bobshell_optarg VARNAME COMMAND [ARGS...]
bobshell_optarg() {
	if bobshell_isset "$1"; then
		bobshell_optarg=$(bobshell_getvar "$1")
		shift
		"$@" "$bobshell_optarg"
		unset bobshell_optarg
	else
		shift
		"$@"
	fi
}