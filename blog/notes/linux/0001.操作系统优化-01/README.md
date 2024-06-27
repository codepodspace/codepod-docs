

```sh

sudo sysctl -w vm.overcommit_memory=1
sudo sysctl -w vm.drop_caches=1
sudo sysctl -w vm.zone_reclaim_mode=0
sudo sysctl -w vm.max_map_count=655360
sudo sysctl -w vm.dirty_background_ratio=50
sudo sysctl -w vm.dirty_ratio=50
sudo sysctl -w vm.dirty_writeback_centisecs=360000
sudo sysctl -w vm.page-cluster=3
sudo sysctl -w vm.swappiness=1

echo 'ulimit -n 655350' >> /etc/profile
echo '* hard nofile 655350' >> /etc/security/limits.conf

echo '* hard memlock      unlimited' >> /etc/security/limits.conf
echo '* soft memlock      unlimited' >> /etc/security/limits.conf

```