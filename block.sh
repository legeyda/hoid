

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/code/defun.sh




hoid_block() {
	case "$1" in
		(start)
			shift
			hoid_block_start "$@"
			;;
		(end)
			shift
			hoid_block_end "$@"
			;;
		(*)
			bobshell_die "hoid block: start or end expected"
	esac
}


hoid_block_start() {
	hoid_state_push
	hoid_state_init
}

hoid_block_end() {
	hoid_state_pop
}



