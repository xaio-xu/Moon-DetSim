/// 模拟录制器 —— 支持录制/回放双模式引擎，提供执行轨迹的精确复现与差异检测。

pub enum SimEvent {
  RandomDraw(Int64, Int64)
  ClockRead(Int64, Int64)
  TaskScheduled(Int64, String, Int64)
  MessageSent(SimMessage)
  MessageDelivered(SimMessage)
  MessageDropped(SimMessage)
  FaultInjected(Int64, String)
  StorageOp(Int64, String, String)
}

/// 一次模拟运行的完整执行轨迹。
pub struct SimTrace {
  seed : Int64
  events : Array[SimEvent]
  total_steps : Int64
  result_summary : String
}

/// 创建空轨迹。
pub fn new_trace(seed : Int64) -> SimTrace {
  SimTrace::{ seed, events: Array::new(), total_steps: 0L, result_summary: "" }
}

/// 设置轨迹的总步数。
pub fn trace_set_steps(trace : SimTrace, steps : Int64) -> SimTrace {
  SimTrace::{ ..trace, total_steps: steps }
}

/// 设置轨迹的结果摘要。
pub fn trace_set_result(trace : SimTrace, summary : String) -> SimTrace {
  SimTrace::{ ..trace, result_summary: summary }
}

/// 录制器运行模式。
pub enum RecorderMode {
  Recording
  Replaying(SimTrace, Int)
}

/// 模拟录制器 —— 录制/回放双模式状态机。
pub struct SimRecorder {
  seed : Int64
  mode : RecorderMode
  current_step : Int64
}

/// 创建录制模式的录制器。
pub fn SimRecorder::new(seed : Int64) -> SimRecorder {
  SimRecorder::{ seed, mode: RecorderMode::Recording, current_step: 0L }
}

/// 从已有轨迹创建回放模式的录制器。
pub fn SimRecorder::from_trace(trace : SimTrace) -> SimRecorder {
  SimRecorder::{
    seed: trace.seed,
    mode: RecorderMode::Replaying(trace, 0),
    current_step: 0L,
  }
}

/// 检查是否处于录制模式。
pub fn SimRecorder::is_recording(self : SimRecorder) -> Bool {
  match self.mode {
    RecorderMode::Recording => true
    _ => false
  }
}

/// 检查是否处于回放模式。
pub fn SimRecorder::is_replaying(self : SimRecorder) -> Bool {
  match self.mode {
    RecorderMode::Replaying(_, _) => true
    _ => false
  }
}

/// 获取录制器的种子。
pub fn SimRecorder::recorder_seed(self : SimRecorder) -> Int64 {
  self.seed
}

/// 从当前录制器状态构建轨迹。
pub fn SimRecorder::build_trace(
  self : SimRecorder,
  result_summary : String,
) -> SimTrace {
  let trace = new_trace(self.seed)
  let trace = trace_set_steps(trace, self.current_step)
  trace_set_result(trace, result_summary)
}

/// 回放结果枚举。
pub enum ReplayResult {
  Success(Int64)
  Diverged(Int64, String, String)
  Error(String)
}

/// 检查回放是否成功。
pub fn is_success(result : ReplayResult) -> Bool {
  match result {
    ReplayResult::Success(_) => true
    _ => false
  }
}

/// 比较两条轨迹是否一致。
pub fn compare_traces(original : SimTrace, replayed : SimTrace) -> ReplayResult {
  if original.seed != replayed.seed {
    return ReplayResult::Error("种子不匹配")
  }
  if original.total_steps != replayed.total_steps {
    return ReplayResult::Error("步数不匹配")
  }
  ReplayResult::Success(original.total_steps)
}
