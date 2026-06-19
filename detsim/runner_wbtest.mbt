test "runner_推进步数正确" {
  let runner = SimRunner::new(42L)
  let runner = runner.run_steps(100L)
  @test.assert_eq(runner.now(), 100_000L)
}

test "runner_确定性" {
  let r1 = SimRunner::new(100L).run_steps(50L)
  let r2 = SimRunner::new(100L).run_steps(50L)
  @test.assert_eq(r1.now(), r2.now())
}
