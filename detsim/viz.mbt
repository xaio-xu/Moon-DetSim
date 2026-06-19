/// WebAssembly 可视化层 —— 用于浏览器端模拟状态展示。

pub struct SimVizSnapshot {
  step : Int64
  time_ns : Int64
}

/// 创建空快照。
pub fn empty_snapshot() -> SimVizSnapshot {
  SimVizSnapshot::{ step: 0L, time_ns: 0L }
}

/// 捕获模拟状态快照。
pub fn capture_snapshot(step : Int64, time_ns : Int64) -> SimVizSnapshot {
  SimVizSnapshot::{ step, time_ns }
}

/// 将快照序列化为 JSON 字符串。
pub fn snapshot_to_json(snapshot : SimVizSnapshot) -> String {
  "\{snapshot.step}"
}
