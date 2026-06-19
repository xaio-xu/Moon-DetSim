# Moon DetSim

面向 MoonBit 异步程序的确定性模拟测试框架。

## 项目简介

Moon DetSim 将程序运行时中的一切非确定性来源（I/O、时钟、随机数、网络、
任务调度）替换为模拟的、确定性的替代实现。给定相同的种子，模拟器始终产生
完全相同的执行轨迹，使得分布式系统中那些难以捉摸的 Bug 可以像放录像一样
逐指令精确回放。

这一方法论已被 FoundationDB 和 TigerBeetle 验证——前者凭借确定性模拟做到
SQL 数据库领域最低 Bug 率，后者在金融数据库中实现了零 Bug 承诺。

## 核心模块

| 模块 | 说明 |
|------|------|
| **SimRng** | 层级种子随机数生成器，基于 SplitMix64 算法。每个子操作从父种子派生独立 RNG，确保操作增删不影响已有随机序列 |
| **SimClock** | 确定性逻辑时钟，支持时间推进、跳跃、漂移注入。附带 SimInstant 瞬时值类型 |
| **SimStorage** | 内存级模拟文件系统，支持读写删除、存在性检查。所有操作纯内存执行，无真实 I/O |
| **SimNetwork** | 确定性模拟网络，支持节点管理、链路配置、消息发送投递、延迟和丢包控制 |
| **DeterministicExecutor** | 单线程确定性任务调度器，所有异步任务按 RNG 派生优先级排序执行 |
| **故障注入模型** | 网络故障（丢包/重排）、时钟故障（漂移）、存储故障（磁盘满/损坏）、进程故障（崩溃/挂起/慢响应） |
| **录制与回放** | SimRecorder 支持录制/回放双模式，SimTrace 记录完整执行轨迹，回放引擎支持差异检测 |
| **场景 DSL** | 声明式故障注入实验编排 |
| **Wasm 可视化** | SimVizSnapshot 支持模拟状态导出，适配浏览器端可视化 |

## 快速开始

```moonbit
// 创建确定性模拟执行器
let config = default_sim_config(42L)
let exec = DeterministicExecutor::new(config)

// 读取模拟时钟
let time = exec.clock()

// 使用确定性随机数生成器
let rng = exec.rng()
let (rng, value) = rng.next_int64()

// 写入模拟存储
let storage = SimStorage::new()
let storage = storage.write("/data.txt", Bytes::new(0))

// 创建模拟网络并发送消息
let net = SimNetwork::new(rng, SimClock::zero(rng))
let net = net.add_node("node-a")
```

## 运行测试

```bash
moon test
```

当前通过 22 个白盒测试，覆盖 RNG、时钟、存储、网络、执行器和录制模块。

## 参考项目

- [FoundationDB Deterministic Simulation Testing](https://apple.github.io/foundationdb/testing.html) — 层级种子模型、flow 系统设计理念
- [TigerBeetle VOPR](https://github.com/tigerbeetle/tigerbeetle) — 模拟驱动开发方法论
- [Rust turmoil](https://github.com/tokio-rs/turmoil) — 网络故障模型 API 设计参考

## 许可证

Apache 2.0
