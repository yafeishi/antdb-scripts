sudo vi /etc/security/limits.conf 
antdb soft nproc 65536
antdb hard nproc 65536
antdb soft nofile 278528
antdb hard nofile 278528
antdb soft stack unlimited
antdb soft core unlimited
antdb hard core unlimited
antdb soft memlock 250000000
antdb hard memlock 250000000