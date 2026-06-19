/// 确定性模拟网络 —— 消息传递、链路配置与故障注入。

pub struct SimLinkConfig {
  base_latency_ns : Int64
  jitter_ns : Int64
  drop_rate : Double
}

/// 默认链路配置：可靠、低延迟（1ms）。
pub fn default_link() -> SimLinkConfig {
  SimLinkConfig::{ base_latency_ns: 1_000_000L, jitter_ns: 0L, drop_rate: 0.0 }
}

/// 模拟网络中的消息。
pub struct SimMessage {
  id : Int64
  from : String
  to : String
  payload : Bytes
  sent_at : Int64
  deliver_at : Int64
}

/// 节点运行状态。
pub enum NodeStatus {
  Running
  Stopped
}

pub struct SimNode {
  id : String
  status : NodeStatus
}

/// 模拟网络 —— 包含节点集合、链路配置、消息队列和投递历史。
pub struct SimNetwork {
  nodes : Map[String, SimNode]
  links : Map[String, SimLinkConfig]
  outbox : Array[SimMessage]
  delivered : Array[SimMessage]
  rng : SimRng
  clock : SimClock
  next_msg_id : Int64
}

pub fn SimNetwork::new(rng : SimRng, clock : SimClock) -> SimNetwork {
  SimNetwork::{
    nodes: Map([], capacity=8),
    links: Map([], capacity=8),
    outbox: Array::new(),
    delivered: Array::new(),
    rng,
    clock,
    next_msg_id: 0L,
  }
}

/// 向网络中添加节点。
pub fn SimNetwork::add_node(self : SimNetwork, id : String) -> SimNetwork {
  let nodes = self.nodes
  nodes.set(id, SimNode::{ id, status: NodeStatus::Running })
  SimNetwork::{ ..self, nodes }
}

/// 设置节点间的链路配置（有向）。
pub fn SimNetwork::set_link(self : SimNetwork, from : String, to : String, config : SimLinkConfig) -> SimNetwork {
  let links = self.links
  links.set("\{from}->\{to}", config)
  SimNetwork::{ ..self, links }
}

/// 设置节点运行状态。
pub fn SimNetwork::set_node_status(self : SimNetwork, node_id : String, status : NodeStatus) -> SimNetwork {
  let nodes = self.nodes
  match nodes.get(node_id) {
    Some(node) => nodes.set(node_id, SimNode::{ id: node.id, status })
    None => ()
  }
  SimNetwork::{ ..self, nodes }
}

/// 查询节点状态。
pub fn SimNetwork::node_status(self : SimNetwork, node_id : String) -> Option[NodeStatus] {
  match self.nodes.get(node_id) {
    Some(node) => Some(node.status)
    None => None
  }
}

/// 在网络中发送消息，返回更新后的网络和消息 ID。
pub fn SimNetwork::send(
  self : SimNetwork,
  from : String,
  to : String,
  payload : Bytes,
) -> (SimNetwork, Int64) {
  let msg_id = self.next_msg_id
  let now = self.clock.now()
  let key = "\{from}->\{to}"
  let link = match self.links.get(key) {
    Some(l) => l
    None => default_link()
  }
  let (rng, dropped) = self.rng.next_double()
  let deliver_at = if dropped < link.drop_rate { -1L } else { now + link.base_latency_ns }
  let msg = SimMessage::{
    id: msg_id, from, to, payload,
    sent_at: now, deliver_at: if deliver_at < now { now } else { deliver_at },
  }
  let outbox = self.outbox
  outbox.push(msg)
  (SimNetwork::{ ..self, rng, outbox, next_msg_id: msg_id + 1L }, msg_id)
}

/// 投递所有到期消息，返回更新后的网络和已投递消息列表。
pub fn SimNetwork::deliver_pending(self : SimNetwork, clock : SimClock) -> (SimNetwork, Array[SimMessage]) {
  let now = clock.now()
  let pending : Array[SimMessage] = Array::new()
  let remaining : Array[SimMessage] = Array::new()
  for msg in self.outbox {
    if msg.deliver_at <= now && msg.deliver_at >= 0L {
      pending.push(msg)
    } else {
      remaining.push(msg)
    }
  }
  let delivered = self.delivered
  for msg in pending {
    delivered.push(msg)
  }
  (SimNetwork::{ ..self, outbox: remaining, delivered }, pending)
}

/// 查询飞行中的消息数量。
pub fn SimNetwork::messages_in_flight(self : SimNetwork) -> Int {
  self.outbox.length()
}
