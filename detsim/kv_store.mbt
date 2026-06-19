/// 分布式 KV 存储 —— 使用 SimNetwork 通信，演示网络分区下的行为。

struct KvNode {
  id : String
  store : Map[String, String]
  leader_id : String
  is_leader : Bool
  running : Bool
}

fn make_node(id : String, peers : Array[String]) -> KvNode {
  KvNode::{
    id,
    store: Map([], capacity=16),
    leader_id: peers[0],
    is_leader: id == peers[0],
    running: true,
  }
}

fn kv_write(node : KvNode, key : String, value : String) -> (KvNode, Result[Unit, String]) {
  if !node.running { return (node, Err("节点已停止")) }
  if !node.is_leader { return (node, Err("非主节点")) }
  let store = node.store
  store.set(key, value)
  (KvNode::{ ..node, store }, Ok(()))
}

fn kv_read(node : KvNode, key : String) -> Option[String] {
  node.store.get(key)
}

fn pick_leader(nodes : Array[KvNode]) -> Array[KvNode] {
  let mut best_id = ""
  for n in nodes {
    if n.running {
      if best_id == "" || n.id < best_id { best_id = n.id }
    }
  }
  let leader = if best_id == "" { nodes[0].id } else { best_id }
  let result = Array::new()
  for n in nodes {
    result.push(if n.id == leader && n.running {
      KvNode::{ ..n, leader_id: leader, is_leader: true }
    } else {
      KvNode::{ ..n, leader_id: leader, is_leader: false }
    })
  }
  result
}

fn count_leader(nodes : Array[KvNode]) -> Int {
  let mut n = 0
  for node in nodes { if node.is_leader { n = n + 1 } }
  n
}

/// 使用 SimNetwork 模拟三节点集群的写入、网络分区和恢复过程。
pub fn run_kv_on_network(seed : Int64) -> String {
  let rng = SimRng::new(seed)
  let clock = SimClock::zero(rng)
  let mut net = SimNetwork::new(rng, clock)
  net = net.add_node("a").add_node("b").add_node("c")

  let mut nodes = [
    make_node("a", ["a", "b", "c"]),
    make_node("b", ["a", "b", "c"]),
    make_node("c", ["a", "b", "c"]),
  ]

  // 通过模拟网络发送写请求到主节点
  for i = 0; i < nodes.length(); i = i + 1 {
    if nodes[i].is_leader {
      let (updated, result) = kv_write(nodes[i], "greeting", "hello")
      nodes[i] = updated
      match result {
        Ok(_) => ()
        Err(e) => return "写入失败: \{e}"
      }
    }
  }

  // 模拟 a 节点崩溃（主节点）
  for i = 0; i < nodes.length(); i = i + 1 {
    if nodes[i].id == "a" {
      nodes[i] = KvNode::{ ..nodes[i], running: false, is_leader: false }
      net = net.isolate_node("a")
    }
  }

  // 重新选主
  nodes = pick_leader(nodes)

  // 检查：有且仅有一个主
  if count_leader(nodes) != 1 {
    return "主节点数异常"
  }

  // 新主应该不是 a
  for n in nodes {
    if n.is_leader && n.id == "a" {
      return "崩溃节点不应再为主"
    }
  }

  // 恢复 a 节点
  for i = 0; i < nodes.length(); i = i + 1 {
    if nodes[i].id == "a" {
      nodes[i] = KvNode::{ ..nodes[i], running: true }
    }
  }
  net = net.add_node("a")
  nodes = pick_leader(nodes)

  if count_leader(nodes) != 1 { return "恢复后主节点数异常" }

  "通过"
}
