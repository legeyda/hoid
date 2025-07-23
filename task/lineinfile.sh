



# shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/cli/parse.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/cli/setup.sh



bobshell_cli_setup hoid_task_lineinfile --var=hoid_task_lineinfile__search --param --default-unset s search
bobshell_cli_setup hoid_task_lineinfile --var=hoid_task_lineinfile__search_type --flag --flag-value=fixed --default-value=fixed f fixed
bobshell_cli_setup hoid_task_lineinfile --var=hoid_task_lineinfile__search_type --flag --flag-value=regex --default-value=fixed r regex


# 
hoid_task_lineinfile() {
	bobshell_cli_parse hoid_task_lineinfile "$@"
	shift "$bobshell_cli_shift"

	hoid_task_lineinfile__line="$1"
	hoid_task_lineinfile__file="$2"
	: "${hoid_task_lineinfile__search:=$hoid_task_lineinfile__line}"


	hoid --name 'line in file' \
			--env hoid_task_lineinfile__search_type \
			--env hoid_task_lineinfile__line \
			--env hoid_task_lineinfile__file \
			--env hoid_task_lineinfile__search \
			block start

	# shellcheck disable=SC2016
	hoid script var:hoid_task_lineinfile_script

	hoid block end
}


hoid_task_lineinfile_function=$(cat<<\EOF
hoid_task_lineinfile() {
	if [ ! -f "$hoid_task_lineinfile__file" ]; then
		echo "file not found: $hoid_task_lineinfile__file"
		return 1
	fi

	if [ -s "$hoid_task_lineinfile__file" ]; then
		_hoid_task_lineinfile__match=false
		_hoid_task_lineinfile__temp_search_type="${hoid_task_lineinfile__search_type:-fixed}"
		_hoid_task_lineinfile__temp_search="${hoid_task_lineinfile__search:-$hoid_task_lineinfile__line}"
		if [ fixed = "$_hoid_task_lineinfile__temp_search_type" ]; then
			if grep -q -F "$_hoid_task_lineinfile__temp_search" "$hoid_task_lineinfile__file"; then
				_hoid_task_lineinfile__match=true
			fi
		elif [ regex = "$_hoid_task_lineinfile__temp_search_type" ]; then
			if grep -q "$_hoid_task_lineinfile__temp_search" "$hoid_task_lineinfile__file"; then
				_hoid_task_lineinfile__match=true
			fi
		else
			echo "unknown value of hoid_task_lineinfile__search_type: $hoid_task_lineinfile__search_type" 1>&2
			return 1
		fi
		unset _hoid_task_lineinfile__temp_search_type _hoid_task_lineinfile__temp_search

		if [ true != "$_hoid_task_lineinfile__match" ]; then
			printf "\n%s" "$hoid_task_lineinfile__line" >> "$hoid_task_lineinfile__file"
		fi
	else
		printf "%s" "$hoid_task_lineinfile__line" > "$hoid_task_lineinfile__file"
	fi
}
EOF
)

hoid_task_lineinfile_script="set -eu
$hoid_task_lineinfile_function
hoid_task_lineinfile
"