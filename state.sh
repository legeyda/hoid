

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/eqvar.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack/push.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/stack/pop.sh

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
	bobshell_event_fire hoid_event_state_dump
}

hoid_state_load() {
	eval "$1"
	bobshell_event_fire hoid_event_state_load
}

