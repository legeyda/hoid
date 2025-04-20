
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/str/quote.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/misc/subcommand.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh
shelduck import ./install/docker.sh

hoid_task_docker() {
	bobshell_subcommand hoid_task_docker "$@"
}

hoid_task_docker_image() {
	bobshell_subcommand hoid_task_docker_image "$@"
}


# fun: hoid docker load --input file:image.tar.gz
hoid_task_docker_image_load() {
	_hoid_task_docker_load__input=stdin:
	unset _hoid_task_docker_load__platform
	_hoid_task_docker_load__quiet=false
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-i|--input)
				_hoid_task_docker_load__input="$2"
				shift 2
				;;

			(--plaform)
				_hoid_task_docker_load__platform="$2"
				shift 2
				;;

			(-q|--quiet)
				_hoid_task_docker_load__quiet=true
				shift 1
				;;

			(-*)
				bobshell_die "hoid_lib_install: unrecognized option: $1"
				;;
					
			(*)
				break
		esac
	done

	_hoid_task_docker_load__script='docker load'
	if bobshell_isset _hoid_task_docker_load__platform; then
		_q=$(bobshell_quote "$_hoid_task_docker_load__platform")
		_hoid_task_docker_load__script="$_hoid_task_docker_load__script --platform $_q"
		unset _q _hoid_task_docker_load__platform
	fi

	if [ true = "$_hoid_task_docker_load__quiet" ]; then
		_hoid_task_docker_load__script="$_hoid_task_docker_load__script --quiet"
	fi
	unset _hoid_task_docker_load__quiet


	unset hoid_task_docker_image_load__temp
	if bobshell_locator_is_file "$_hoid_task_docker_load__input" _hoid_task_docker_load__file; then
		if   bobshell_ends_with "$_hoid_task_docker_load__file" .tar.gz; then
			# docker load accepts tar.gz
			true
		elif bobshell_ends_with "$_hoid_task_docker_load__file" .tar; then
			hoid_task_docker_image_load__temp=$(mktemp -d)
			hoid_task_docker_image_load__basename=$(basename "$_hoid_task_docker_load__file")
			cp "$_hoid_task_docker_load__file" "$hoid_task_docker_image_load__temp/$hoid_task_docker_image_load__basename.tar"
			(cd "$hoid_task_docker_image_load__temp" && gzip "$hoid_task_docker_image_load__basename.tar")
			_hoid_task_docker_load__input="file://hoid_task_docker_image_load__temp/$hoid_task_docker_image_load__basename.gz"
			unset hoid_task_docker_image_load__basename
			true
		else
			bobshell_die 'wrong image archive format'
		fi
	fi

	hoid script --input "$_hoid_task_docker_load__input" "$_hoid_task_docker_load__script"
	unset _hoid_task_docker_load__input
	if bobshell_isset hoid_task_docker_image_load__temp; then
		rm -rf "$hoid_task_docker_image_load__temp"
		unset hoid_task_docker_image_load__temp
	fi

}

hoid_task_docker_image_save() {
	_hoid_task_docker_save__output=stdout:
	unset _hoid_task_docker_save__platform
	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-o|--output)
				_hoid_task_docker_save__output="$2"
				shift 2
				;;

			(--plaform)
				_hoid_task_docker_save__platform="$2"
				shift 2
				;;

			(-*)
				bobshell_die "hoid_lib_install: unrecognized option: $1"
				;;
					
			(*)
				break
		esac
	done

	# 
	bobshell_str_quote "$@"
	bobshell_result_read hoid_task_docker_image_save__args
	if bobshell_isset _hoid_task_docker_save__platform; then
		bobshell_str_quote "$_hoid_task_docker_save__platform"
		hoid_task_docker_image_save__args="--output $bobshell_result_1 $hoid_task_docker_image_save__args"
	fi

	

	_hoid_task_docker_image_save__temp=$(mktemp -d)

	# shellcheck disable=SC2016
	hoid script --output "file://$_hoid_task_docker_image_save__temp/image.tar.gz" 'x=$(mktemp -d)
docker image save --output "$x/image.tar" '"$hoid_task_docker_image_save__args"'
gzip -c "$x/image.tar" # todo what if gzip not installed
rm -rf "$x"
'

	if bobshell_locator_is_file "$_hoid_task_docker_save__output" _hoid_task_docker_save__file \
				&& bobshell_ends_with "$_hoid_task_docker_save__file" .tar.gz; then
		bobshell_resource_copy "file://$_hoid_task_docker_image_save__temp/image.tar.gz" "$_hoid_task_docker_save__output"
	else
		bobshell_redirect_output "$_hoid_task_docker_save__output" gunzip -c "$_hoid_task_docker_image_save__temp/image.tar.gz"	
	fi

	rm -rf "$_hoid_task_docker_image_save__temp"
	unset _hoid_task_docker_image_save__temp
}
