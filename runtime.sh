

shelduck import https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh

hoid_remote_mock_src() {
	# https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main
	shelduck resolve remote_mock.sh
}

for task_name in command directory flush script shelduck shell; do
	bobshell_eval stdin: <<EOF
hoid_task_${task_name}_src() {
	shelduck resolve task/${task_name}.sh
}
EOF
done

offline_resolve() {
	true
}