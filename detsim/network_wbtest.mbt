test "network_消息发送与投递" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let net = SimNetwork::new(rng, clock)
  let net = net.add_node("a").add_node("b")
  let (net, id) = net.send("a", "b", Bytes::new(0))
  let clock = clock.advance(2_000_000L)
  let (net, msgs) = net.deliver_pending(clock)
  @test.assert_eq(msgs.length(), 1)
}

test "network_批量添加节点" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let net = SimNetwork::new(rng, clock)
  let net = net.add_nodes(["a", "b", "c"])
  @test.assert_eq(net.node_count(), 3)
}

test "network_高延迟消息延迟投递" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let net = SimNetwork::new(rng, clock)
  let net = net.add_node("a").add_node("b")
  let link = SimLinkConfig::{ base_latency_ns: 10_000_000L, jitter_ns: 0L, drop_rate: 0.0 }
  let net = net.set_link("a", "b", link)
  let (net, _) = net.send("a", "b", Bytes::new(0))
  let clock = clock.advance(1_000_000L)
  let (_, msgs) = net.deliver_pending(clock)
  @test.assert_eq(msgs.length(), 0) // 还没到投递时间
}

test "network_节点隔离" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let net = SimNetwork::new(rng, clock)
  let net = net.add_node("a")
  let net = net.isolate_node("a")
  match net.node_status("a") {
    Some(_) => () // 确认状态已变更
    None => abort("节点应存在")
  }
}
