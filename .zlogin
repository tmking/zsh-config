if [[ -o interactive ]]; then
	if [ -s ~/.plan ]; then
        	echo
        	cat ~/.plan
	fi

	export MAILHOST=$(hostname)
	export MAILUSER=$USER
#	export G_BROKEN_FILENAMES=1

#	eval `ssh-agent` >/dev/null 2>&1
#	echo "SSH_AGENT_PID=$SSH_AGENT_PID" > ~/.ssh/agent
#	echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> ~/.ssh/agent

#	keychain -q id_rsa EE946A6E
fi
