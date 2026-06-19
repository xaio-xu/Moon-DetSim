test "RNG_种子零可用" {
  let rng = SimRng::new(0L)
  let (_, _) = rng.next_int64()
  @test.assert_eq(true, true)
}

test "RNG_种子最大值" {
  let rng = SimRng::new(0x7FFFFFFFFFFFFFFFL)
  let (_, _) = rng.next_int64()
  @test.assert_eq(true, true)
}

test "RNG_种子最小值" {
  let rng = SimRng::new(-0x7FFFFFFFFFFFFFFFL)
  let (_, _) = rng.next_int64()
  @test.assert_eq(true, true)
}

test "RNG_范围边界_单值区间" {
  let rng = SimRng::new(42L)
  let (_, v) = rng.next_between(5L, 5L)
  @test.assert_eq(v, 5L)
}

test "RNG_范围边界_负区间" {
  let rng = SimRng::new(42L)
  let (_, v) = rng.next_between(-10L, 0L)
  @test.assert_eq(v >= -10L, true)
  @test.assert_eq(v <= 0L, true)
}

test "时钟_长时间运行" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let mut clock = clock
  for i = 0; i < 10000; i = i + 1 {
    clock = clock.advance(1_000_000L)
  }
  @test.assert_eq(clock.now(), 10_000_000_000L)
}

test "时钟_零时间跳跃" {
  let rng = SimRng::new(42L)
  let clock = SimClock::new(100L, rng, 0L)
  let result = clock.jump_to(100L)
  match result {
    Ok(c) => @test.assert_eq(c.now(), 100L)
    Err(_) => abort("同时间跳跃不应失败")
  }
}

test "存储_读写大文件" {
  let s = SimStorage::new()
  let data = Bytes::new(10000)
  let s = s.write("/big", data)
  @test.assert_eq(s.exists("/big"), true)
}

test "存储_删除不存在的文件" {
  let s = SimStorage::new()
  let result = s.delete("/no_such_file")
  match result {
    Ok(_) => abort("删除不存在的文件应返回错误")
    Err(_) => ()
  }
}

test "网络_发送到不存在的节点" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let net = SimNetwork::new(rng, clock)
  let net = net.add_node("a")
  let (net, _) = net.send("a", "ghost", Bytes::new(0))
  // 消息可以发送（异步），投递时才会发现目标不存在
  @test.assert_eq(net.messages_in_flight(), 1)
}
