

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh

shelduck import ../lineinfile.sh


hoid_task_install_pyenv() {
	hoid --name 'install pyenv' block start
	
	hoid_task_install_pyenv__check
	if ! bobshell_result_check; then
		hoid_task_install_pyenv__do
		hoid_task_install_pyenv__check
		if ! bobshell_result_check; then
			bobshell_die 'something wrong: pyenv invalid after installation'
		fi
	fi

	hoid block end
}

hoid_task_install_pyenv__check() {
	hoid script --output var:hoid_task_install_pyenv__check 'pyenv install --list 2>/dev/null || true'
	if bobshell_contains "$hoid_task_install_pyenv__check" 3.13.5; then
		bobshell_result_set true
	else
		bobshell_result_set false
	fi
}


hoid_task_install_pyenv__do() {

	# shellcheck disable=SC2016
	hoid script '# lineinfile remote function
'"$hoid_task_lineinfile_function"'

checkout_pyenv() {
	: "${PYENV_ROOT:=$HOME/.pyenv}"
	export PYENV_ROOT
	if [ ! -x "$PYENV_ROOT/bin/pyenv" ]; then
		mkdir -p "$PYENV_ROOT"
		if command -v git 2>/dev/null; then
			git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
		else
			docker run --interactive --rm --name=kvix-dev --env=HOME --env=PYENV_ROOT \
				--volume="$PYENV_ROOT:$PYENV_ROOT" --workdir="$PYENV_ROOT" \
				"--user=$(id -u):$(id -g)" \
				alpine/git:v2.49.1 clone https://github.com/pyenv/pyenv.git .
		fi
	fi
}
checkout_pyenv

# lineinfile arguments
hoid_task_lineinfile__search_type=fixed
hoid_task_lineinfile__autocreate_file=false
hoid_task_lineinfile__autocreate_dirs=false

# ensure bash config files exist
cd "$HOME"
touch -a .bashrc
if [ ! -f .bash_profile ] && [ ! -f .bash_login ]; then
	touch -a ".profile"
fi

# apply configuration
for hoid_task_lineinfile__file in .bashrc .profile .bash_profile .bash_login; do
	if [ ! -f "$hoid_task_lineinfile__file" ]; then
		continue
	fi

	hoid_task_lineinfile__line='"'"'export PYENV_ROOT="$HOME/.pyenv"'"'"'
	hoid_task_lineinfile__search="$hoid_task_lineinfile__line"
	hoid_task_lineinfile

	hoid_task_lineinfile__line='"'"'[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'"'"'
	hoid_task_lineinfile__search="$hoid_task_lineinfile__line"
	hoid_task_lineinfile

	hoid_task_lineinfile__line='"'"'eval "$(pyenv init - bash)"'"'"'
	hoid_task_lineinfile__search="$hoid_task_lineinfile__line"
	hoid_task_lineinfile
done

'
}
