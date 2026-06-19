test "kv_正常写入读取" {
  let r = run_kv_demo(42L)
  @test.assert_eq(r, "通过")
}

test "kv_确定性_同种子" {
  let r1 = run_kv_demo(100L)
  let r2 = run_kv_demo(100L)
  @test.assert_eq(r1, r2)
}

test "kv_不同种子可能不同" {
  let r1 = run_kv_demo(100L)
  let r2 = run_kv_demo(200L)
  // 结果应该都是"通过"（不变性保持），即便执行路径可能不同
  @test.assert_eq(r1.contains("通过"), true)
  @test.assert_eq(r2.contains("通过"), true)
}

test "kv_崩溃后重新选举" {
  // 多次运行验证崩溃后总能选出新主
  for seed = 1L; seed < 10L; seed = seed + 1L {
    let r = run_kv_demo(seed)
    @test.assert_eq(r, "通过")
  }
}
