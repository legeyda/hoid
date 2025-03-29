
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/str/split.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/event/var/listen.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/template.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

hoid_finder_state_change_event_listener() {
	hoid_finder_template_apply
}
bobshell_event_listen hoid_state_change_event hoid_finder_state_change_event_listener


hoid_finder_template_apply() {
	hoid_finder_path_ensure
	hoid_finder_path_instance=
	hoid_finder_path_reverse_instance=
	bobshell_str_split "$hoid_finder_path" : hoid_finder_item_loop
}

# var: HOID_FINDER_PATH
#      hoid_finder_path
hoid_finder_path_ensure() {
	if bobshell_isset hoid_finder_path; then
		return
	fi
	if bobshell_isset HOID_FINDER_PATH; then
		hoid_finder_path=$HOID_FINDER_PATH
		return
	fi

	hoid_finder_path="$HOME/.local/share/hoid/profile/{{ hoid_profile }}";
	hoid_finder_path="$hoid_finder_path:$HOME/.local/share/hoid/common"
	hoid_finder_path="$hoid_finder_path:./hoid/profile/{{ hoid_profile }}"
	hoid_finder_path="$hoid_finder_path:./hoid/common"
	hoid_finder_path="$hoid_finder_path:."
}

hoid_finder_item_loop() {
	_hoid_finder_item_loop__template="$1"
	bobshell_mustache var:_hoid_finder_item_loop__template var:_hoid_finder_item_loop__result
	_hoid_finder_item_loop__result=$(bobshell_quote "$_hoid_finder_item_loop__result")

	hoid_finder_path_instance="$hoid_finder_path_instance $_hoid_finder_item_loop__result"
	hoid_finder_path_reverse_instance="$_hoid_finder_item_loop__result $hoid_finder_path_reverse_instance"

	unset _hoid_finder_item_loop__template _hoid_finder_item_loop__result
}



hoid_finder_find_all() {
	unset _hoid_finder_get_all__any
	for _hoid_finder_get_all__item in $hoid_finder_path_reverse_instance; do
		if [ -e "$_hoid_finder_get_all__item/$1" ]; then
			if [ true = "${_hoid_finder_get_all__any:-false}" ]; then
				printf %s ' '
			fi
			bobshell_quote "$_hoid_finder_get_all__item/$1"
			_hoid_finder_get_all__any=true
		fi
	done
	if ! bobshell_isset _hoid_finder_get_all__any; then
		return 1
	fi
	unset _hoid_finder_get_all__any
}

hoid_finder_find_one() {
	for _hoid_finder_get_one__item in $hoid_finder_path_instance; do
		if [ -e "$_hoid_finder_get_one__item/$1" ]; then
			printf %s "$_hoid_finder_get_one__item/$1"
			unset _hoid_finder_get_one__item
			return
		fi
	done
	unset _hoid_finder_get_one__item
	return 1
}



# hoid_find_files
