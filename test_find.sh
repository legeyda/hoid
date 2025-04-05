


shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ./find.sh

init_dir() {
	set -- "target/$1"
	rm -rf "$1"
	mkdir -p "$1"
	cd "$1"
}

test_find_all() {
	init_dir test_find_all
	mkdir -p dir1/testprof dir2/testprof dir3/testprof

	HOID_PATH='dir1/{{ hoid_profile }}:dir2/{{ hoid_profile }}:dir3/{{ hoid_profile }}'
	bobshell_event_fire hoid_setup_event
	bobshell_event_var_set hoid_profile testprof

	echo hello > dir1/testprof/file.txt
	echo hi    > dir3/testprof/file.txt


	found=$(hoid_find_all file.txt)
	assert_equals 'dir3/testprof/file.txt dir1/testprof/file.txt'  "$found"

}

test_find_one() {
	init_dir test_find_all
	mkdir -p dir1/testprof dir2/testprof dir3/testprof

	HOID_PATH='dir1/{{ hoid_profile }}:dir2/{{ hoid_profile }}:dir3/{{ hoid_profile }}'
	bobshell_event_fire hoid_setup_event
	bobshell_event_var_set hoid_profile testprof

	echo hello > dir1/testprof/file.txt
	echo hi    > dir3/testprof/file.txt


	found=$(hoid_find_one file.txt)
	assert_equals dir1/testprof/file.txt "$found"

}