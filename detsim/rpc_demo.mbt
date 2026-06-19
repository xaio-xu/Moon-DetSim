/// RPC 调用示例 —— 演示超时和重试机制的确定性测试。

struct RpcClient {
  timeout_ns : Int64
  max_retries : Int
  backoff_ns : Int64
}

fn new_client() -> RpcClient {
  RpcClient::{ timeout_ns: 5_000_000_000L, max_retries: 3, backoff_ns: 1_000_000_000L }
}

fn call_service(
  client : RpcClient,
  server_ok : Bool,
  latency_ns : Int64,
  clock : SimClock,
) -> (SimClock, Bool) {
  if !server_ok {
    (clock.sleep(client.timeout_ns + 1L), false)
  } else if latency_ns <= client.timeout_ns {
    (clock.sleep(latency_ns), true)
  } else {
    // 超时后重试
    let clock = clock.sleep(client.timeout_ns)
    let clock = clock.sleep(client.backoff_ns)
    (clock.sleep(latency_ns / 2L), true)
  }
}

pub fn run_rpc_demo(seed : Int64) -> String {
  let rng = SimRng::new(seed)
  let clock = SimClock::zero(rng)
  let client = new_client()

  // 正常调用
  let (clock, ok) = call_service(client, true, 1_000_000L, clock)
  if !ok { return "正常调用失败" }

  // 慢服务触发超时重试
  let (clock, ok) = call_service(client, true, 6_000_000_000L, clock)
  if !ok { return "重试失败" }

  // 服务不可用
  let (_, ok) = call_service(client, false, 0L, clock)
  if ok { return "应该失败的调用却成功了" }

  "通过"
}
