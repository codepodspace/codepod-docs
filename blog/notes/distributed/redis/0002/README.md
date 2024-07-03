

## 常见分布式锁方案对比
| 分类       | 方案      |
|----------|---------|
| 基于数据库 | 基于mysql |

实现原理:

表唯一索引

优点：

1. 表增加唯一索引 
2. 加锁：执行insert语句，若报错，则表明加锁失败 
3. 解锁：执行delete语句	完全利用DB现有能力，实现简单	

缺点：

1. 锁无超时自动失效机制，有死锁风险
2. 不支持锁重入，不支持阻塞等待
3. 操作数据库开销大，性能不高|

| 分类       | 方案                              |
|----------|---------------------------------|
| 基于数据库 | 基于MongoDB findAndModify原子操作 |

优点：

1. 加锁：执行findAndModify原子命令查找document，若不存在则新增 
2. 解锁：删除document	实现也很容易，较基于MySQL唯一索引的方案，性能要好很多

缺点：

1. 大部分公司数据库用MySQL，可能缺乏相应的MongoDB运维、开发人员
2. 锁无超时自动失效机制

| 分类               | 方案          |
|------------------|-------------|
| 基于分布式协调系统 | 基于ZooKeeper |

优点：

1. 加锁：在/lock目录下创建临时有序节点，判断创建的节点序号是否最小。若是，则表示获取到锁；否，则则watch /lock目录下序号比自身小的前一个节点
2. 解锁：删除节点

缺点：

1. 由zk保障系统高可用
2. Curator框架已原生支持系列分布式锁命令，使用简单	需单独维护一套zk集群，维保成本高

| 分类     | 方案          |
|--------|-------------|
| 基于缓存 | 基于redis命令 |

实现原理

1. 加锁：执行setnx，若成功再执行expire添加过期时间
2. 解锁：执行delete命令
        
优点：

实现简单，相比数据库和分布式系统的实现，该方案最轻，性能最好	

缺点：

1. setnx和expire分2步执行，非原子操作；若setnx执行成功，但expire执行失败，就可能出现死锁
2. delete命令存在误删除非当前线程持有的锁的可能 
3. 不支持阻塞等待、不可重入


| 分类      | 方案        |
|---------|-----------|
| 基于redis | Lua脚本能力 |

实现原理：

1. 加锁：执行SET lock_name random_value EX seconds NX 命令
2. 解锁：执行Lua脚本，释放锁时验证

优点：

同`基于缓存`；实现逻辑上也更严谨，除了单点问题，生产环境采用用这种方案，问题也不大。

缺点：

不支持锁重入，不支持阻塞等待	


## 分布式锁需满足四个条件

为了确保分布式锁可用，我们至少要确保锁的实现同时满足以下四个条件：

- 互斥性。在任意时刻，只有一个客户端能持有锁。
- 不会发生死锁。即使有一个客户端在持有锁的期间崩溃而没有主动解锁，也能保证后续其他客户端能加锁。
- 解铃还须系铃人。加锁和解锁必须是同一个客户端，客户端自己不能把别人加的锁给解了，即不能误解锁。
- 具有容错性。只要大多数Redis节点正常运行，客户端就能够获取和释放锁。

## Redisson分布式锁的实现

Redisson 支持单点模式、主从模式、哨兵模式、集群模式，这里以单点模式为例：

```java
Config config = new Config();
config.useSingleServer().setAddress("redis://127.0.0.1:5379").setPassword("123456").setDatabase(0);
// 2.构造RedissonClient
RedissonClient redissonClient = Redisson.create(config);
// 3.获取锁对象实例（无法保证是按线程的顺序获取到）
RLock rLock = redissonClient.getLock(lockKey);
try {
    /**
     * 4.尝试获取锁
     * waitTimeout 尝试获取锁的最大等待时间，超过这个值，则认为获取锁失败
     * leaseTime   锁的持有时间,超过这个时间锁会自动失效（值应设置为大于业务处理的时间，确保在锁有效期内业务能处理完）
     */
    boolean res = rLock.tryLock((long)waitTimeout, (long)leaseTime, TimeUnit.SECONDS);
    if (res) {
        //成功获得锁，在这里处理业务
    }
} catch (Exception e) {
    throw new RuntimeException("aquire lock fail");
}finally{
    //无论如何, 最后都要解锁
    rLock.unlock();
}

```

加锁&解锁Lua脚本

```lua
if (redis.call('exists', KEYS[1]) == 0) then
    redis.call('hset', KEYS[1], ARGV[2], 1);
    redis.call('pexpire', KEYS[1], ARGV[1]);
    return nil;
end;
 
-- 若锁存在，且唯一标识也匹配：则表明当前加锁请求为锁重入请求，故锁重入计数+1，并再次设置锁过期时间
if (redis.call('hexists', KEYS[1], ARGV[2]) == 1) then
    redis.call('hincrby', KEYS[1], ARGV[2], 1);
    redis.call('pexpire', KEYS[1], ARGV[1]);
    return nil;
end;
 
-- 若锁存在，但唯一标识不匹配：表明锁是被其他线程占用，当前线程无权解他人的锁，直接返回锁剩余过期时间
return redis.call('pttl', KEYS[1]);

```