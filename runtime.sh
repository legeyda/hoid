

#shelduck import https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/defun.sh


hoid_remote_mock_src=$(shelduck resolve ./remote_mock.sh)
# shellcheck disable=SC2016
bobshell_defun hoid_remote_mock_src 'printf %s "$hoid_remote_mock_src"'

for task_name in command directory script shelduck shell; do
	task_src=$(shelduck resolve task/${task_name}.sh)
	bobshell_putvar hoid_task_${task_name}_src "$task_src"
	# shellcheck disable=SC2016
	bobshell_defun "hoid_task_${task_name}_src" 'bobshell_getvar hoid_task_${task_name}_src'
done
