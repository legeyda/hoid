#!/usr/bin/env shelduck_run
shelduck import https://raw.githubusercontent.com/legeyda/hoid/refs/heads/main/hoid.sh

HOID_SCRIPT=narrowboat

hoid find-all narrowboat/env.sh \
		bobshell_eval

hoid --become true --become-password 123 --target ubuntu24server --name 'example hoid script' block start
hoid -n 'create working directory' directory ./target/hello
hoid -n 'print greeting' command echo hello


if bobshell_isset PAYREGISTRY_DEPLOY_SECRET_PASSWORD; then
	HOID_SECRET_PASSWORD="$PAYREGISTRY_DEPLOY_SECRET_PASSWORD"
fi


hoid copy --secret POSTGRES_PASSWORD var:POSTGRES_PASSWORD





hoid --chdir /opt/narrowboat --name 'install narrowboat' \
     block start

hoid --chdir runway --name 'install runway src' \
     block start
hoid checkout git@github.com:legeyda/runway.git .
#hoid --chdir runway command ./run install
hoid block end



hoid git clone git@github.com:legeyda/runway.git /opt/narrowboat/runway

hoid copy 

hoid --chdir /opt/narrowboat/runway --name 'provide runway project src' \
     block start
hoid copy https://github.com/legeyda/tailsitter/archive/refs/heads/main.zip ./tailsitter-main.zip
hoid command unzip --file tailsitter-main.zip
hoid --chdir ./tailsitter-main command ./run install
hoid block end

hoid docker load 