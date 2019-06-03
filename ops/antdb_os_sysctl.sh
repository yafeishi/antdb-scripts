
#关闭防火墙


# centos 6
servcie iptables stop 
chkconfig iptables off

# centos 7
systemctl stop firewalld.service
systemctl disable firewalld.service

# suse12
systemctl stop SuSEfirewall2.service
systemctl disable SuSEfirewall2.service

#关闭numa和transparent_hugepage

# redhat/centos 6
# vim /etc/grub.conf
default=0
timeout=5
splashimage=(hd0,0)/grub/splash.xpm.gz
hiddenmenu
title Red Hat Enterprise Linux 6 (2.6.32-504.el6.x86_64)
        root (hd0,0)
        kernel /vmlinuz-2.6.32-504.el6.x86_64 ro root=/dev/mapper/vg_os-lv_os rd_NO_LUKS LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto rd_LVM_LV=vg_os/lv_os  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet numa=off transparent_hugepage=never
# 关闭服务
service tuned stop
chkconfig tuned off
service ktune stop
chkconfig ktune off


# redhat/centos 7
grubby --update-kernel=ALL --args="numa=off transparent_hugepage=never"  # 该命令修改的是这个文件：/etc/grub2.cfg
grub2-mkconfig 

# 关闭服务
systemctl stop tuned
systemctl disable tuned

这种方式修改后，重启主机生效。

# 重启后，验证grub的cmdline：
cat /proc/cmdline


#检查 numa
numactl --hardware
预期结果为：
available: 1 nodes (0)

#检查 transparent_hugepage
cat /sys/kernel/mm/transparent_hugepage/enabled
预期结果为：
always madvise [never]



cat >>  /etc/sysctl.conf << EOF
# add for antdb
kernel.shmmax=137438953472 137438953472
kernel.shmall=53689091
kernel.shmmni=4096
kernel.msgmnb=4203520
kernel.msgmax=65536
kernel.msgmni=32768
kernel.sem=501000 641280000 501000 12800

fs.aio-max-nr=6553600
fs.file-max=26289810
net.core.rmem_default=8388608
net.core.rmem_max=16777216
net.core.wmem_default=8388608
net.core.wmem_max=16777216
net.core.netdev_max_backlog=262144
net.core.somaxconn= 65535
net.ipv4.tcp_rmem=8192 87380 16777216
net.ipv4.tcp_wmem=8192 65536 16777216
net.ipv4.tcp_max_syn_backlog=262144
net.ipv4.tcp_keepalive_time=180
net.ipv4.tcp_keepalive_intvl=10
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_fin_timeout=1
net.ipv4.tcp_synack_retries=1
net.ipv4.tcp_syn_retries=1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_tw_recycle=1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_max_tw_buckets=256000
net.ipv4.tcp_retries1=2
net.ipv4.tcp_retries2=3
vm.dirty_background_ratio=5
vm.dirty_expire_centisecs=6000
vm.dirty_writeback_centisecs=500
vm.dirty_ratio=20
vm.overcommit_memory=0
vm.overcommit_ratio= 120
vm.vfs_cache_pressure = 100
vm.swappiness=10
vm.drop_caches = 2
vm.min_free_kbytes = 2048000
vm.zone_reclaim_mode=0
kernel.core_uses_pid=1
kernel.core_pattern=/data1/antdb/coredump/core-%e-%p-%t
kernel.sysrq=0
EOF

# 生效
sysctl -p

