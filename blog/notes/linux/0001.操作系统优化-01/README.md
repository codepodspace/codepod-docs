## 调优脚本

```bash

sudo sysctl -w vm.overcommit_memory=1
sudo sysctl -w vm.drop_caches=1
sudo sysctl -w vm.zone_reclaim_mode=0
sudo sysctl -w vm.dirty_background_ratio=50
sudo sysctl -w vm.dirty_ratio=50
sudo sysctl -w vm.dirty_writeback_centisecs=360000
sudo sysctl -w vm.swappiness=1

echo 'ulimit -n 655350' >> /etc/profile
echo '* hard nofile 655350' >> /etc/security/limits.conf

echo '* hard memlock      unlimited' >> /etc/security/limits.conf
echo '* soft memlock      unlimited' >> /etc/security/limits.conf

```

## 参数调优说明

引用来源：(https://blog.csdn.net/weixin_41312759/article/details/136597236)

### 虚拟内存相关的内核参数调优

> vm.overcommit_memory：

- `描述`：vm.overcommit_memory 参数控制了内核如何进行内存的过量分配。它决定了内核在内存不足时是否允许分配更多的内存。

这个参数有三种模式：

    0 表示严格模式，不允许过量分配；
    1 表示启发式模式，允许适度的过量分配；
    2 表示总是允许过量分配。

- `调优`：在大多数情况下，建议使用默认的启发式模式（1），因为它可以提供较好的性能和安全性平衡。如果系统经常出现OOM（Out of Memory）错误，可能需要调整这个参数，但要小心，因为不恰当的设置可能导致系统稳定性问题。


> dirty_background_ratio

- `描述`：dirty_background_ratio 是一个百分比值，它控制了当脏页（被修改过的页面）占总可用内存的百分比达到多少时，后台写入（background writeout）开始将脏页写回磁盘。
- `调优`：如果系统中有`大量的写操作`，可能需要`调低`这个比例，以确保不会因为脏页过多而导致突然的、大量的写操作（也称为"突发IO"）。这可以减少写操作对系统性能的影响。


> vm.swappiness：

- `描述`：vm.swappiness 参数控制了内核在进行内存回收时倾向于回收文件缓存还是使用交换空间。它的值范围从0到100，数值越高，内核越倾向于使用交换空间。
- `调优`：如果系统有足够的内存并且不经常使用交换空间，可以降低 vm.swappiness 的值，这样可以减少对磁盘I/O的需求，提高系统性能。然而，如果系统内存紧张，适当增加 vm.swappiness 的值可以帮助防止内存耗尽的情况。

> vm.dirty_background_ratio 和 vm.dirty_ratio

- `描述`：这两个参数分别控制了脏页（被修改过的页面）的写回时机。vm.dirty_background_ratio 是在后台开始回写脏页的阈值，而 vm.dirty_ratio 是在内存压力较大时强制回写脏页的阈值。
- `调优`：这些参数的调整取决于系统的工作负载和对数据一致性的需求。通常情况下，不需要调整这些参数，除非有特定的性能问题需要解决。

> vm.drop_caches

这个参数用于控制内核在内存压力下回收哪些类型的缓存（包括页面缓存、目录项缓存和inode缓存）。

    0 不执行清空操作。
    1 清空页缓存中的所有脏（dirty）页。
    2 清空页缓存中的所有脏页和已使用（used）的页。
    3 清空页缓存中的所有脏页、已使用的页和已清理（cleaned）的页。

> vm.zone_reclaim_mode

这个参数用于控制在NUMA架构下，内核如何回收不同节点上的内存。适当调整可以帮助改善跨NUMA节点的内存访问性能。

    0 关闭zone_reclaim模式，可以从其他zone或NUMA节点回收内存
    1 打开zone_reclaim模式，这样内存回收只会发生在本地节点内
    2 在本地回收内存时，可以将cache中的脏数据写回硬盘，以回收内存。
    4 可以用swap方式回收内存。

> dirty_writeback_centisecs

`描述`：vm.dirty_writeback_centisecs 参数控制了在内核认为有必要的情况下，脏页在被写入磁盘之前可以在内存中驻留的时间。
参数控制内核脏数据刷新进程pdflush的运行间隔。单位是（1/100）s。
默认值是500，也就是5s，如果系统是持续的写入动作，那么建议降低数值，这样可以把尖峰的写操作削平成多次写操作；
相反，如果系统是短期的尖峰式写操作，并且写入数据不大且内存又比较富裕，那么应该增大此数。

`调优`：这个值可以根据工作负载的类型进行调整，以确保系统不会因为过多的脏页而突然进行大量的写操作。

### 磁盘I/O相关的内核参数调优

> block.readahead

- 这个参数控制着系统进行文件读取操作时的预读行为。通过增加预读的大小（以KB为单位），可以减少磁盘的寻道次数和应用程序的I/O等待时间，从而提高读取速度。

> block.write_cache_size

- 这个参数用于设置写入缓存的大小。适当增加写入缓存可以提高写操作的性能，因为数据首先被写入缓存，然后在适当的时机再写入物理磁盘。这样做可以减少直接对磁盘的写操作，提高整体的I/O性能。

