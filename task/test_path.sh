
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../util.sh
shelduck import ./path.sh
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh


test_path() {
	mkcd
	hoid_testlocal_run do_test_path
}

do_test_path() {
	_do_test_path=binbinbin
	mkdir -p "$_do_test_path"

	hoid_task_path_configs=cfgfile
	hoid command touch -a "$hoid_task_path_configs"
	hoid path "$_do_test_path"
	hoid command --output var:do_test_path_cfg cat "$hoid_task_path_configs"

	eval "$do_test_path_cfg"
	assert_contains "$PATH" "$_do_test_path"
}