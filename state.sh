

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/misc/eqvar.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/stack/push.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/stack/pop.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/stack/size.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/result/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/result/check.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/event/fire.sh


hoid_state_validate() {
	bobshell_result_set true
	bobshell_event_fire hoid_state_validate_event
	if ! bobshell_result_check; then
		bobshell_result_read _hoid_state_validate__result _hoid_state_validate__message || true
		bobshell_die "hoid: state validation error: ${_hoid_state_validate__message:-unknown error}"
	fi
}

hoid_state_init() {
	bobshell_event_fire hoid_event_state_init "$@"
}

# fun: hoid_state_push
hoid_state_push() {
	bobshell_event_fire hoid_state_push_event
}

# fun: hoid_state_pop
hoid_state_pop() {
	bobshell_event_fire hoid_state_pop_event
}


# fun: hoid_state_dump
hoid_state_dump() {
	if bobshell_isset hoid_state_valid; then
		printf "hoid_state_valid='%s'\n" "$hoid_state_valid"
	else
		printf '%s\n' 'unset hoid_state_valid'
	fi
	bobshell_event_fire hoid_event_state_dump 
	# todo rename to hoid_state_dump_event
	# todo instead of writing to stdout write to locator or return result or write to buffer or something
}


bobshell_event_listen hoid_state_push_event hoid_state_push_event_listener
hoid_state_push_event_listener() {
	bobshell_redirect_output var:_hoid_state_push_event_listener__dump hoid_state_dump
	bobshell_stack_push hoid_state_stack "$_hoid_state_push_event_listener__dump"
	unset _hoid_state_push_event_listener__dump
}

bobshell_event_listen hoid_state_pop_event hoid_state_pop_event_listener
hoid_state_pop_event_listener() {	
	bobshell_stack_size hoid_state_stack
	bobshell_result_assert _hoid_state_pop_event_listener__size
	
	if [ "$_hoid_state_pop_event_listener__size" = 0 ]; then
		bobshell_die 'invalid state stack'
	fi
	unset _hoid_state_pop_event_listener__size

	bobshell_stack_pop hoid_state_stack 
	bobshell_result_assert _hoid_state_pop_event_listener__value

	eval "$_hoid_state_pop_event_listener__value"
	unset _hoid_state_pop_event_listener__value

}

