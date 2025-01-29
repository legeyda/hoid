
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh

hoid_task_copy() {
	hoid_task_copy_quoted_dest=$(bobshell_quote "$2")
	hoid_driver_write "cat > $hoid_task_copy_quoted_dest" < "$1"
	unset hoid_task_copy_quoted_dest
}