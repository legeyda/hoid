
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/ssh.sh


hoid_task_reboot() {
	hoid --become true command /sbin/reboot
	hoid_buffer_flush
	sleep 5
	for _hoid_task_reboot__i in $(seq 20); do
		if hoid_driver_write 'echo "hoid reboot: check ready"'; then
			unset _hoid_task_reboot__i
			return
		fi
		sleep 2
	done
	bobshell_die "hoid_task_reboot: timeout"
	unset _hoid_task_reboot__i
}