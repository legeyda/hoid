

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/resource/copy.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/redirect/io.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/redirect/output.sh



bobshell_event_listen hoid_event_subcommand '
	if [ buffer = "$1" ]; then
		shift
		bobshell_subcommand hoid_buffer "$@"
		bobshell_result_set true
		return
	fi
	bobshell_result_set false
'


hoid_buffer_printf() {
	bobshell_redirect_output var:_hoid_buffer_printf printf "$@"
	hoid_buffer_write "$_hoid_buffer_printf"
	unset _hoid_buffer_printf
}

hoid_buffer_write() {
	# todo auto flush if buffer too big
	hoid_buffer="${hoid_buffer:-}$*"
}

# fun: hoid_buffer_flush1
# env: hoid_buffer
hoid_buffer_flush() {
	if [ -z "${hoid_buffer:-}" ]; then
		return
	fi
	_hoid_buffer_flush__input=stdin:
	_hoid_buffer_flush__output=stdout:
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
		bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected: locator"
				_hoid_buffer_flush__input="$2"
				shift 2
				;;
			(-o|--output)
		bobshell_isset_2 "$@" || bobshell_die "hoid: option $1: argument expected: locator"
				_hoid_buffer_flush__output="$2"
				shift 2
				;;
			(-*)
				bobshell_die "unexpected option: $1"
				;;
			(*)
				bobshell_die "unexpected parameter: $1"
		esac
	done
	if bobshell_isset_1 "$@"; then
		bobshell_die "hoid flush: takes no arguments"
	fi

	if [ -z "${hoid_buffer:-}" ]; then
		return
	fi

	bobshell_event_fire hoid_event_buffer_rewrite # todo deprecate hoid_event_buffer_rewrite in favor of hoid_buffer_flush_start_event

	if [ -z "${hoid_buffer:-}" ]; then
		return
	fi

	bobshell_event_fire hoid_buffer_flush_start_event
	bobshell_redirect_io "$_hoid_buffer_flush__input" "$_hoid_buffer_flush__output" hoid_driver_write "$hoid_buffer"
	hoid_buffer=
	bobshell_event_fire hoid_buffer_flush_end_event

	unset _hoid_buffer_flush__input _hoid_buffer_flush__output
}
