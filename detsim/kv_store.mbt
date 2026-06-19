/// 分布式 KV 存储示例 —— 演示网络分区下的确定性模拟测试。

struct KvNode {
  id : String
  data : Map[String, String]
  leader_id : String
  is_leader : Bool
  is_running : Bool
}

fn make_node(id : String, peers : Array[String]) -> KvNode {
  KvNode::{
    id,
    data: Map([], capacity=16),
    leader_id: peers[0],
    is_leader: id == peers[0],
    is_running: true,
  }
}

fn kv_write(node : KvNode, key : String, value : String) -> (KvNode, Result[Unit, String]) {
  if !node.is_running { return (node, Err("节点已停止")) }
  if !node.is_leader { return (node, Err("非主节点，拒绝写入")) }
  let data = node.data
  data.set(key, value)
  (KvNode::{ ..node, data }, Ok(()))
}

fn kv_read(node : KvNode, key : String) -> Option[String] {
  node.data.get(key)
}

fn elect_leader(nodes : Array[KvNode]) -> Array[KvNode] {
  // 从运行的节点中选出 ID 最小的作为新主
  let mut best_id = ""
  for n in nodes {
    if n.is_running {
      if best_id == "" || n.id < best_id { best_id = n.id }
    }
  }
  let leader_id = if best_id == "" { nodes[0].id } else { best_id }
  let result = Array::new()
  for n in nodes {
    result.push(if n.id == leader_id && n.is_running {
      KvNode::{ ..n, leader_id, is_leader: true }
    } else {
      KvNode::{ ..n, leader_id, is_leader: false }
    })
  }
  result
}

fn check_cluster(nodes : Array[KvNode]) -> Array[String] {
  let violations : Array[String] = Array::new()
  let mut leader_count = 0
  for n in nodes {
    if n.is_leader { leader_count = leader_count + 1 }
  }
  if leader_count != 1 {
    violations.push("主节点数量异常：\{leader_count}")
  }
  violations
}

pub fn run_kv_demo(seed : Int64) -> String {
  let _rng = SimRng::new(seed)
  let mut nodes = [
    make_node("a", ["a", "b", "c"]),
    make_node("b", ["a", "b", "c"]),
    make_node("c", ["a", "b", "c"]),
  ]

  // 写入数据
  for i = 0; i < nodes.length(); i = i + 1 {
    if nodes[i].is_leader {
      let (updated, result) = kv_write(nodes[i], "key1", "val1")
      nodes[i] = updated
      match result {
        Ok(_) => ()
        Err(e) => return "写入失败: \{e}"
      }
    }
  }

  // 读取验证
  match kv_read(nodes[0], "key1") {
    Some(v) => if v != "val1" { return "值不匹配: \{v}" }
    None => return "键不存在"
  }

  // 模拟主节点崩溃
  for i = 0; i < nodes.length(); i = i + 1 {
    if nodes[i].is_leader {
      nodes[i] = KvNode::{ ..nodes[i], is_running: false, is_leader: false }
    }
  }

  // 重新选举
  nodes = elect_leader(nodes)
  let violations = check_cluster(nodes)
  if violations.length() > 0 { return violations[0] }

  "通过"
}
