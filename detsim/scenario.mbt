/// 场景编排 DSL —— 声明式故障注入实验描述。

pub struct Scenario {
  name : String
  description : String
  seed : Int64
  expected_outcome : String
}

/// 场景动作类型。
pub enum ScenarioAction {
  CrashNode(String)
  RestartNode(String)
  ClockJump(Int64)
  PacketLoss(Double)
}

/// 创建新场景。
pub fn new_scenario(name : String, seed : Int64) -> Scenario {
  Scenario::{ name, description: "", seed, expected_outcome: "" }
}

/// 设置场景描述。
pub fn scenario_with_description(
  scenario : Scenario,
  desc : String,
) -> Scenario {
  Scenario::{ ..scenario, description: desc }
}

/// 设置预期结果。
pub fn scenario_expect(scenario : Scenario, outcome : String) -> Scenario {
  Scenario::{ ..scenario, expected_outcome: outcome }
}
