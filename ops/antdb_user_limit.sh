sudo vi /etc/security/limits.conf 
antdb soft nproc 37268
antdb hard nproc 32768
antdb soft nofile 102400
antdb hard nofile 278528
antdb soft stack unlimited
antdb hard memlock 250000000