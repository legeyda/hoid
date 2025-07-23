





shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/random/int.sh
shelduck import ../path.sh


hoid_task_install_binary_function=$(cat<<'EOF'

# https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
bobshell_isset_2() {
	eval "test \"\${2+defined}\" = defined"
}

# fun: hoid_task_install_binary COPYFROMFILE [FILENAME]
# txt: does not add bindir to path!
hoid_task_install_binary() {
	if [ ! -r "$1" ]; then
		echo "hoid_task_install_binary: source file not found: $1" 1>&2
		return 1
	fi

	if [ -n "${hoid_task_install_binary__bindir:-}" ]; then
		_hoid_task_install_binary__xbindir="$hoid_task_install_binary__bindir"
	elif [ $(id -u) -eq 0 ]; then
		_hoid_task_install_binary__xbindir=/opt/bin
	else
		_hoid_task_install_binary__xbindir="$HOME/.local/bin"
	fi

	mkdir -p "$_hoid_task_install_binary__xbindir"

	if bobshell_isset_2 "$@"; then
		_hoid_task_install_binary__name="$2"
	else
		_hoid_task_install_binary__name=$(basename "$1")
	fi

	rm -f "$_hoid_task_install_binary__xbindir/$_hoid_task_install_binary__name"
	cp "$1" "$_hoid_task_install_binary__xbindir/$_hoid_task_install_binary__name"
	chmod ugo+x "$_hoid_task_install_binary__xbindir/$_hoid_task_install_binary__name"
	
	hoid_task_path "$_hoid_task_install_binary__xbindir"


	unset _hoid_task_install_binary__xbindir _hoid_task_install_binary__name
	 
}
EOF
)

hoid_task_install_binary_function="
$hoid_task_path_function

$hoid_task_install_binary_function

"


bobshell_cli_setup hoid_task_install_binary --var=_hoid_task_install_binary__remote --flag r remote-src

# fun: hoid_task_install_binary SRCLOCATOR [NAME]
hoid_task_install_binary() {

	bobshell_cli_parse hoid_task_install_binary "$@"
	shift "$bobshell_cli_shift"

	if [ true = "$_hoid_task_install_binary__remote" ] && bobshell_locator_parse "$1"; then
		bobshell_die "hoid_task_install_binary: sourcelocators not supported when remote flag is on "
	fi

	#
	if bobshell_isset_2 "$@"; then
		_hoid_task_install_binary__name="$2"
	elif [ true = "$_hoid_task_install_binary__remote" ]; then
		_hoid_task_install_binary__name=$(basename "$1")
	elif bobshell_locator_is_file "$1" _hoid_task_install_binary__srcref; then
		_hoid_task_install_binary__name=$(basename "$_hoid_task_install_binary__srcref")
		unset _hoid_task_install_binary__srcref
	else
		bobshell_die "hoid_task_install_binary: cannot get binary name"
	fi

	# 
	_hoid_task_install_binary__src=$(date +%Y-%m-%d_%H-%M-%S_%N)
	bobshell_random_int
	_hoid_task_install_binary__src="/tmp/hoid_task_install_binary_temp_${_hoid_task_install_binary__src}_$bobshell_result_2"
	hoid --name 'hoid task install binary' block start
	hoid command mkdir -p "$_hoid_task_install_binary__src"
	_hoid_task_install_binary__src="$_hoid_task_install_binary__src/$_hoid_task_install_binary__name"


	# 
	hoid copy "$1" "$_hoid_task_install_binary__src"

	# shellcheck disable=SC2016
	hoid --env _hoid_task_install_binary__src --env _hoid_task_install_binary__name script '
'"$hoid_task_install_binary_function"'

hoid_task_install_binary "$_hoid_task_install_binary__src" "$_hoid_task_install_binary__name"
'

	hoid block end
	unset _hoid_task_install_binary__src _hoid_task_install_binary__name

}