/// 核心模拟执行器 —— 类型定义与默认实现。

pub struct SimExecutorConfig {
  seed : Int64
  enable_recording : Bool
  max_steps : Int64
  enable_faults : Bool
}

/// 创建默认的执行器配置。
pub fn default_sim_config(seed : Int64) -> SimExecutorConfig {
  SimExecutorConfig::{
    seed,
    enable_recording: true,
    max_steps: 1_000_000L,
    enable_faults: true,
  }
}

/// 故障注入点 —— 执行器生命周期中可注入故障的事件。
pub enum FaultInjectionPoint {
  BeforeTaskSpawn(String)
  AfterTaskComplete(String)
  BeforeMessageDeliver(Int64)
  AfterMessageDeliver(Int64)
  BeforeStorageOp(String)
  AfterStorageOp(String)
  PeriodicCheck(Int64)
}

/// 确定性执行器 —— 单线程确定性任务调度器。
pub struct DeterministicExecutor {
  config : SimExecutorConfig
  rng : SimRng
  clock : SimClock
  storage : SimStorage
  network : SimNetwork
  step : Int64
}

pub fn DeterministicExecutor::new(
  config : SimExecutorConfig,
) -> DeterministicExecutor {
  let rng = SimRng::new(config.seed)
  DeterministicExecutor::{
    config,
    rng,
    clock: SimClock::zero(rng),
    storage: SimStorage::new(),
    network: SimNetwork::new(rng, SimClock::zero(rng)),
    step: 0L,
  }
}

/// 便捷构造函数，仅需种子。
pub fn new_executor(seed : Int64) -> DeterministicExecutor {
  DeterministicExecutor::new(default_sim_config(seed))
}

/// 调度一个任务（基于 RNG 分配确定性优先级）。
pub fn DeterministicExecutor::schedule_task(
  self : DeterministicExecutor,
  name : String,
) -> DeterministicExecutor {
  let (new_rng, _priority) = self.rng.next_int64()
  DeterministicExecutor::{ ..self, rng: new_rng, step: self.step + 1L }
}

/// 推进模拟一步。
pub fn DeterministicExecutor::step(
  self : DeterministicExecutor,
) -> DeterministicExecutor {
  let clock = self.clock.advance(1_000L)
  DeterministicExecutor::{ ..self, clock, step: self.step + 1L }
}

/// 检查模拟是否已耗尽（达到最大步数限制）。
pub fn DeterministicExecutor::is_exhausted(
  self : DeterministicExecutor,
) -> Bool {
  self.step >= self.config.max_steps
}

pub fn DeterministicExecutor::clock(self : DeterministicExecutor) -> Int64 {
  self.clock.now()
}

pub fn DeterministicExecutor::rng(self : DeterministicExecutor) -> SimRng {
  self.rng
}

pub fn DeterministicExecutor::root_seed(self : DeterministicExecutor) -> Int64 {
  self.config.seed
}

pub fn DeterministicExecutor::step_count(self : DeterministicExecutor) -> Int64 {
  self.step
}
