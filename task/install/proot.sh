
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/random/int.sh
shelduck import ./binary.sh


hoid_task_install_proot__make_script=$(cat<<'EOF'
#!/bin/sh
set -eux

apt-get --yes update
apt-get --yes --no-install-recommends install build-essential libtalloc-dev uthash-dev libarchive-dev

cd /projsrc

# https://github.com/proot-me/proot?tab=readme-ov-file#compiling
make -C src loader.elf loader-m32.elf build.h # first build the config and loader
make -C src proot care # then compile PRoot and CARE
# make -C test # run test suite
EOF
)



hoid_task_install_proot() {
	hoid_task_install_proot_check
	if bobshell_result_check; then
		return
	fi

	hoid --name 'proot build & install' block start

	_hoid_task_install_proot__random_name=$(date +%Y-%m-%d_%H-%M-%S_%N)
	_hoid_task_install_proot__random_name="hoid-install-proot-$_hoid_task_install_proot__random_name"

 

	mkdir -p "/tmp/$_hoid_task_install_proot__random_name"
	hoid command mkdir -p "/tmp/$_hoid_task_install_proot__random_name"

	if bobshell_command_available docker; then
		git clone https://github.com/proot-me/proot.git "/tmp/$_hoid_task_install_proot__random_name/projsrc"
		docker run --rm --name="$_hoid_task_install_proot__random_name" --interactive --volume="/tmp/$_hoid_task_install_proot__random_name/projsrc:/projsrc" ubuntu:24.04 sh <<EOF
$hoid_task_install_proot__make_script
EOF
		hoid install binary "file:///tmp/$_hoid_task_install_proot__random_name/projsrc/src/proot"
	else
		hoid git clone https://github.com/proot-me/proot.git "/tmp/$_hoid_task_install_proot__random_name/projsrc"
		hoid command --input stdin: docker run --rm --name="$_hoid_task_install_proot__random_name" --interactive --volume="/tmp/$_hoid_task_install_proot__random_name/projsrc:/projsrc" ubuntu:24.04 sh <<EOF
$hoid_task_install_proot__make_script
EOF
		hoid install binary --remote-source "/tmp/$_hoid_task_install_proot__random_name/projsrc/src/proot"
	fi
	hoid block end

	hoid install package libtalloc2
	
	hoid_task_install_proot_check
	if ! bobshell_result_check; then
		return 1
	fi

}
	
hoid_task_install_proot_check() {
	hoid buffer flush
	hoid --name 'proot check installed' block start
	
	# shellcheck disable=SC2016
	hoid script --output var:_hoid_task_install_proot_check__output 'proot --version && echo "hoid_task_install_proot: installed" || true'
	hoid block end
	if bobshell_contains "$_hoid_task_install_proot_check__output" 'hoid_task_install_proot: installed'; then
		bobshell_result_set true
	else
		bobshell_result_set false
	fi

	
}


