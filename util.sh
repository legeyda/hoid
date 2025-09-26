
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/event/var/set.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/event/var/unset.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/event/listen.sh




hoid_util_state_dump() {
	while bobshell_isset_1 "$@"; do
		if bobshell_isset "$1"; then
			_hoid_util_state_dump__value=$(bobshell_getvar "$1")
			printf "bobshell_event_var_set '%s' '%s'\n" "$1" "$_hoid_util_state_dump__value"
			unset _hoid_util_state_dump__value
		else
			printf 'bobshell_event_var_unset %s\n' "$1"
		fi
		shift
	done
}



hoid_util_select() {
	while bobshell_isset "$@"; do
		bobshell_resource_copy "$1" var:_hoid_util_select
		if [ -z "$_hoid_util_select" ]; then
			continue
		fi
		bobshell_result_set true "$_hoid_util_select"
		return
	done
	bobshell_result_set false
}


mkcd() {
	if bobshell_isset_1 "$@"; then
		mkdir -p "$1"
		cd "$1" || return 1
	else
		_mkcd__dir=$(mktemp -d)
		cd "$_mkcd__dir"
		unset _mkcd_dir	
	fi
}

hoid_testvm_run() {
	hoid --driver ssh --target "$HOID_TEST_TARGET" --name block start

	"$@"

	hoid buffer flush
	hoid block end
}

hoid_testlocal_run() {
	hoid --driver local --name hoid_testlocal_run block start

	"$@"

	hoid buffer flush
	hoid block end
}

hoid_testcontainer_run() {

	_hoid_testcontainer_run__tempdir=$(mktemp -d)
	docker build "$_hoid_testcontainer_run__tempdir" -f- -t temp_hoid_testcontainer_image <<'EOF'
FROM ubuntu:24.04
RUN apt-get --yes update
RUN apt-get --yes install sudo
EOF
	rm -rf _hoid_testcontainer_run__tempdir




	hoid_testcontainer_name=temp_hoid_testcontainer
	hoid_testcontainer_stop "$hoid_testcontainer_name"
	_hoid_testcontainer_run__clean="${HOID_TESTCONTAINER_CLEAN:-true}"
	if [ true = "$_hoid_testcontainer_run__clean" ]; then
		bobshell_event_listen bobshell_exit_event "hoid_testcontainer_stop '$hoid_testcontainer_name'" # todo comment out for debug
	fi
	docker run --detach --name "$hoid_testcontainer_name" --rm temp_hoid_testcontainer_image sleep 999
	docker exec --interactive "$hoid_testcontainer_name" apt-get --yes update
	docker exec --interactive "$hoid_testcontainer_name" apt-get --yes install sudo

	hoid --driver docker --target "$hoid_testcontainer_name" --name hoid_testcontainer_name block start

	"$@"

	hoid buffer flush
	hoid block end
	
	if [ true = "$_hoid_testcontainer_run__clean" ]; then
		hoid_testcontainer_stop "$hoid_testcontainer_name" # todo comment out for debug
	fi
	unset _hoid_testcontainer_run__clean 
}


hoid_testcontainer_stop() {
	_hoid_testcontainer_stop="${1:-$hoid_testcontainer_name}"
	if docker inspect "$_hoid_testcontainer_stop" > /dev/null 2>&1; then
		docker rm -f "$_hoid_testcontainer_stop"
	fi
	unset _hoid_testcontainer_stop
}
