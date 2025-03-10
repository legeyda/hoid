
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

hoid_task_shell() {
	if bobshell_resource_parse "$*"; then
		bobshell_resource_copy "$*" var:_hoid_task_shell__value=
		hoid_buffer_write "$_hoid_task_shell__value"
		unset _hoid_task_shell__value
	else
		hoid_buffer_write "$*"
	fi
}



