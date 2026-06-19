test "rpc_正常调用" {
  let r = run_rpc_demo(42L)
  @test.assert_eq(r, "通过")
}

test "rpc_确定性" {
  @test.assert_eq(run_rpc_demo(100L), run_rpc_demo(100L))
}
