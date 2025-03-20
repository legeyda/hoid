

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/eqvar.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack/push.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack/pop.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack/size.sh

hoid_state_init() {
	bobshell_event_fire hoid_event_state_init "$@"
}

# fun: hoid_state_push
hoid_state_push() {
	hoid_state_push_value=$(bobshell_event_fire hoid_event_state_dump)
	bobshell_stack_push hoid_state_stack "$hoid_state_push_value"
	unset hoid_state_push_value
}

# fun: hoid_state_pop
hoid_state_pop() {
	bobshell_stack_size hoid_state_stack
	bobshell_result_assert _hoid_state_pop__size
	
	if [ "$_hoid_state_pop__size" = 0 ]; then
		bobshell_die 'invalid state stack'
	fi
	unset _hoid_state_pop__size

	bobshell_stack_pop hoid_state_stack 
	bobshell_result_assert _hoid_state_pop__value

	hoid_state_load "$_hoid_state_pop__value"
	unset _hoid_state_pop__value
}


# fun: hoid_state_dump
hoid_state_dump() {
	bobshell_event_fire hoid_event_state_dump
}

hoid_state_load() {
	eval "$1"
	bobshell_event_fire hoid_event_state_load
}

