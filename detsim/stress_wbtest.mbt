test "压力_千次RNG确定性" {
  let mut r = SimRng::new(42L)
  let values = Array::new()
  for i = 0; i < 1000; i = i + 1 {
    let (next, v) = r.next_int64()
    r = next
    values.push(v)
  }
  // 同种子重新生成，验证完全一致
  let mut r2 = SimRng::new(42L)
  for i = 0; i < 1000; i = i + 1 {
    let (next, v) = r2.next_int64()
    r2 = next
    @test.assert_eq(v, values[i])
  }
}

test "压力_多节点消息洪泛" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let net = SimNetwork::new(rng, clock)
  let net = net.add_nodes(["n1", "n2", "n3", "n4", "n5"])
  let mut net = net
  // 发送 100 条消息
  let mut sent = 0
  for i = 0L; i < 100L; i = i + 1L {
    let (n, _id) = net.send("n1", "n2", Bytes::new(0))
    net = n
    sent = sent + 1
  }
  @test.assert_eq(sent, 100)
  @test.assert_eq(net.messages_in_flight(), 100)
}

test "压力_存储大量写入" {
  let mut s = SimStorage::new()
  for i = 0L; i < 500L; i = i + 1L {
    let key = "file_\{i}"
    s = s.write(key, Bytes::new(0))
  }
  @test.assert_eq(s.file_count(), 500)
}
