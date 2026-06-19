test "kv_网络模式_正常写入" {
  let r = run_kv_on_network(42L)
  @test.assert_eq(r, "通过")
}

test "kv_网络模式_确定性" {
  @test.assert_eq(run_kv_on_network(100L), run_kv_on_network(100L))
}

test "kv_网络模式_不同种子均通过" {
  for s = 1L; s < 10L; s = s + 1L {
    @test.assert_eq(run_kv_on_network(s), "通过")
  }
}

test "kv_网络模式_崩溃恢复正确" {
  for s = 1L; s < 20L; s = s + 2L {
    let r = run_kv_on_network(s)
    @test.assert_eq(r.contains("异常"), false)
  }
}
