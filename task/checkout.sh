
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/git.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh



# use: hoid_task_checkout GITARCH [TARGETDIR]
# env: hoid_task_checkout_dir
hoid_task_checkout() {
	_hoid_task_checkout__temp=$(bobshell_mktemp -d)
	_hoid_task_checkout__unpack="$_hoid_task_checkout__temp_dir/unpack"
	mkdir -p _hoid_task_checkout__unpack

	if bobshell_ends_with "$1" ".git"; then
		bobshell_git clone "$1" "$_hoid_task_checkout__unpack"
		_hoid_task_checkout__dir="$_hoid_task_checkout__unpack"
	elif bobshell_ends_with "$1" ".tar.gz"; then
		# warning: risky if pipefail disabled
		bobshell_fetch_url "$1" | gunzip --stdout | ( cd "$_hoid_task_checkout__unpack" && tar x )
		
		_hoid_task_checkout__unpack_list=$(ls -1 "$_hoid_task_checkout__unpack")
		if bobshell_contains "$_hoid_task_checkout__unpack_list" "$bobshell_newline" && [ -d "$_hoid_task_checkout__unpack_list" ]; then
			_hoid_task_checkout__dir="$_hoid_task_checkout__unpack/$_hoid_task_checkout__unpack_list"
		else
			_hoid_task_checkout__dir="$_hoid_task_checkout__unpack"
		fi
	fi

	hoid flush
	(cd "$_hoid_task_checkout__dir" && )
}
