/// 故障注入模型 —— 网络、时钟、存储与进程故障的配置与注入逻辑。

pub struct NetworkFaultConfig {
  packet_loss_rate : Double
  reorder_probability : Double
}

/// 创建无故障的默认网络配置。
pub fn no_network_faults() -> NetworkFaultConfig {
  NetworkFaultConfig::{ packet_loss_rate: 0.0, reorder_probability: 0.0 }
}

/// 根据网络故障配置对链路参数进行修改，返回更新后的 RNG 和链路配置。
pub fn apply_network_faults(
  config : NetworkFaultConfig,
  base_link : SimLinkConfig,
  rng : SimRng,
) -> (SimRng, SimLinkConfig) {
  let mut link = base_link
  let mut rng = rng
  if config.packet_loss_rate > 0.0 {
    let (new_rng, roll) = rng.next_double()
    rng = new_rng
    if roll < config.packet_loss_rate {
      link = SimLinkConfig::{ ..link, drop_rate: 1.0 }
    }
  }
  (rng, link)
}

pub struct ClockFaultConfig {
  drift_ppm : Int64
}

/// 创建无故障的默认时钟配置。
pub fn no_clock_faults() -> ClockFaultConfig {
  ClockFaultConfig::{ drift_ppm: 0L }
}

/// 根据时钟故障配置对当前时间进行漂移修正。
pub fn apply_clock_faults(
  config : ClockFaultConfig,
  current_time : Int64,
) -> Int64 {
  let mut time = current_time
  if config.drift_ppm != 0L {
    time = time + current_time * config.drift_ppm / 1000000L
  }
  time
}

pub struct StorageFaultConfig {
  disk_full : Bool
  corruption_probability : Double
}

/// 创建无故障的默认存储配置。
pub fn no_storage_faults() -> StorageFaultConfig {
  StorageFaultConfig::{ disk_full: false, corruption_probability: 0.0 }
}

/// 进程故障类型。
pub enum ProcessFault {
  Crash(String)
  Hang(String, Int64, Int64)
  Slowdown(String, Double)
}

pub struct ProcessFaultConfig {
  crash_probability_per_second : Double
}

/// 创建无故障的默认进程配置。
pub fn no_process_faults() -> ProcessFaultConfig {
  ProcessFaultConfig::{ crash_probability_per_second: 0.0 }
}

/// 检查当前时间是否存在活跃的进程故障。
pub fn active_process_faults(
  config : ProcessFaultConfig,
  rng : SimRng,
) -> (SimRng, Array[ProcessFault]) {
  let faults : Array[ProcessFault] = Array::new()
  let (rng, roll) = rng.next_double()
  if config.crash_probability_per_second > 0.0 && roll < config.crash_probability_per_second {
    faults.push(ProcessFault::Crash("随机节点"))
  }
  (rng, faults)
}

/// 模拟存储故障 —— 根据配置决定写入是否成功。
pub fn simulate_storage_fault(
  config : StorageFaultConfig,
  rng : SimRng,
) -> (SimRng, Bool) {
  if config.disk_full { return (rng, false) }
  let (rng, roll) = rng.next_double()
  let ok = roll >= config.corruption_probability
  (rng, ok)
}

/// 模拟时钟故障 —— 返回经过故障修正后的时间。
pub fn simulate_clock_fault(
  config : ClockFaultConfig,
  current_time : Int64,
  rng : SimRng,
) -> (SimRng, Int64) {
  let time = apply_clock_faults(config, current_time)
  (rng, time)
}
