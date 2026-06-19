/// 模拟运行器 —— 将网络、时钟和故障注入整合为可执行的模拟实验。

pub struct SimRunner {
  network : SimNetwork
  clock : SimClock
  rng : SimRng
  step : Int64
}

pub fn SimRunner::new(seed : Int64) -> SimRunner {
  let rng = SimRng::new(seed)
  let clock = SimClock::zero(rng)
  let network = SimNetwork::new(rng, clock)
  SimRunner::{ network, clock, rng, step: 0L }
}

/// 推进模拟，投递到期消息并更新时钟。
pub fn SimRunner::tick(self : SimRunner) -> SimRunner {
  let clock = self.clock.advance(1_000L)
  let (network, _) = self.network.deliver_pending(clock)
  SimRunner::{ ..self, clock, network, step: self.step + 1L }
}

/// 推进 N 步。
pub fn SimRunner::run_steps(self : SimRunner, n : Int64) -> SimRunner {
  let mut runner = self
  for _i = 0L; _i < n; _i = _i + 1L { runner = runner.tick() }
  runner
}

/// 获取当前模拟时间。
pub fn SimRunner::now(self : SimRunner) -> Int64 {
  self.clock.now()
}

/// 获取已投递消息数。
pub fn SimRunner::delivered(self : SimRunner) -> Int {
  self.network.delivered_count()
}
