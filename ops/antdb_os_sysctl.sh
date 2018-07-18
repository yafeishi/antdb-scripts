
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
vm.dirty_background_ratio=5
vm.dirty_expire_centisecs=6000
vm.dirty_writeback_centisecs=500
vm.dirty_ratio=20
vm.overcommit_memory=2
vm.overcommit_ratio= 120
vm.vfs_cache_pressure = 100
vm.swappiness=10
vm.drop_caches = 2
vm.min_free_kbytes = 2048000
vm.zone_reclaim_mode=0
kernel.core_uses_pid=1
kernel.core_pattern=/data1/antdb/coredump/core-%e-%p-%t
kernel.sysrq=0




#  /etc/grub.conf
numa=off
elevator=deadline

rhel7
/etc/default/grub
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet numa=off"
/boot/grub2/grub.cfg
linux16 /vmlinuz-3.10.0-327.el7.x86_64 root=/dev/mapper/rhel-root ro crashkernel=auto rd.lvm.lv=rhel/root rd.lvm.lv=r
hel/swap rhgb quiet LANG=en_US.UTF-8 numa=off


#
sysctl: setting key "net.core.somaxconn": Invalid argument

