test "回放_同种子一致" {
  let r = run_replay_demo(42L)
  @test.assert_eq(r, "回放一致，通过")
}

test "回放_确定性" {
  @test.assert_eq(run_replay_demo(100L), run_replay_demo(100L))
}

test "回放_多轮验证" {
  for s = 1L; s < 20L; s = s + 1L {
    @test.assert_eq(run_replay_demo(s), "回放一致，通过")
  }
}
