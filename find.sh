
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/str/split.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/event/var/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/template.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh

bobshell_event_listen hoid_setup_event hoid_find_setup_event_listener
hoid_find_setup_event_listener() {
	if bobshell_isset HOID_PATH; then
		bobshell_event_var_set hoid_path "$HOID_PATH"
	else	
		bobshell_event_var_set hoid_path \
			"$HOME/.local/share/hoid/profile/{{ hoid_profile }}:$HOME/.local/share/hoid/common:./hoid/profile/{{ hoid_profile }}:./hoid/common"
	fi
}

bobshell_event_var_listen hoid_profile hoid_find_profile_event_var_listener
hoid_find_profile_event_var_listener() {
	hoid_find_path_instance=
	hoid_find_path_reverse_instance=
	if bobshell_isset hoid_profile; then
		bobshell_str_split "$hoid_path" : hoid_find_item_loop
	fi
}


hoid_find_item_loop() {
	_hoid_find_item_loop__template="$1"
	bobshell_mustache var:_hoid_find_item_loop__template var:_hoid_find_item_loop__result
	_hoid_find_item_loop__result=$(bobshell_quote "$_hoid_find_item_loop__result")

	hoid_find_path_instance="$hoid_find_path_instance $_hoid_find_item_loop__result"
	hoid_find_path_reverse_instance="$_hoid_find_item_loop__result $hoid_find_path_reverse_instance"

	bobshell_result_set true
	unset _hoid_find_item_loop__template _hoid_find_item_loop__result
}



hoid_find_all() {
	unset _hoid_find_get_all__any
	for _hoid_find_get_all__item in $hoid_find_path_reverse_instance; do
		if [ -e "$_hoid_find_get_all__item/$1" ]; then
			if [ true = "${_hoid_find_get_all__any:-false}" ]; then
				printf %s ' '
			fi
			bobshell_quote "$_hoid_find_get_all__item/$1"
			_hoid_find_get_all__any=true
		fi
	done
	if ! bobshell_isset _hoid_find_get_all__any; then
		return 1
	fi
	unset _hoid_find_get_all__any
}

hoid_find_one() {
	for _hoid_find_get_one__item in $hoid_find_path_instance; do
		if [ -e "$_hoid_find_get_one__item/$1" ]; then
			printf %s "$_hoid_find_get_one__item/$1"
			unset _hoid_find_get_one__item
			return
		fi
	done
	unset _hoid_find_get_one__item
	return 1
}



# hoid_find_files
