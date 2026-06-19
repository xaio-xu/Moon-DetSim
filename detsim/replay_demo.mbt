/// 录制与回放演示 —— 展示从故障注入到精确复现的完整流程。

/// 运行一次带故障的模拟，录制轨迹，然后回放验证一致性。
pub fn run_replay_demo(seed : Int64) -> String {
  let config = SimExecutorConfig::{
    seed,
    enable_recording: true,
    max_steps: 1_000_000L,
    enable_faults: true,
  }
  let exec = DeterministicExecutor::new(config)

  // 第一次运行
  let rng = exec.rng()
  let clock = SimClock::zero(rng)
  let mut net = SimNetwork::new(rng, clock)
  net = net.add_nodes(["x", "y", "z"])

  // 发送几条消息
  let (net, _) = net.send("x", "y", Bytes::new(8))
  let (net, _) = net.send("y", "z", Bytes::new(8))

  // 记录轨迹
  let rec = SimRecorder::new(seed)
  let trace = rec.build_trace("第一次运行")

  // 第二次运行（回放模式）
  let rec2 = SimRecorder::from_trace(trace)
  let rng2 = SimRng::new(seed)
  let clock2 = SimClock::zero(rng2)
  let mut net2 = SimNetwork::new(rng2, clock2)
  net2 = net2.add_nodes(["x", "y", "z"])
  let (net2, _) = net2.send("x", "y", Bytes::new(8))
  let (net2, _) = net2.send("y", "z", Bytes::new(8))
  let trace2 = rec2.build_trace("第二次运行")

  // 对比
  let result = compare_traces(trace, trace2)
  match result {
    ReplayResult::Success(_) => "回放一致，通过"
    ReplayResult::Diverged(_, _, _) => "回放不一致，失败"
    ReplayResult::Error(e) => "错误: \{e}"
  }
}
