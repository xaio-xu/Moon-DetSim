///|
test "executor_creation" {
  let config = default_sim_config(42L)
  let exec = DeterministicExecutor::new(config)
  @test.assert_eq(exec.root_seed(), 42L)
  @test.assert_eq(exec.step_count(), 0L)
}

///|
test "executor_step" {
  let exec = new_executor(42L)
  let exec = exec.schedule_task("task-1")
  let exec = exec.step()
  @test.assert_eq(exec.step_count() > 0L, true)
}

///|
test "executor_not_exhausted" {
  let exec = new_executor(42L)
  @test.assert_eq(exec.is_exhausted(), false)
}

///|
test "storage_write_read" {
  let storage = SimStorage::new()
  let data = Bytes::new(0)
  let storage = storage.write("/test.txt", data)
  @test.assert_eq(storage.exists("/test.txt"), true)
}

///|
test "network_add_node" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let net = SimNetwork::new(rng, clock)
  let net = net.add_node("node-a")
  match net.node_status("node-a") {
    Some(status) => @test.assert_eq(true, true)
    None => abort("Node should exist")
  }
}

///|
test "recorder_mode" {
  let rec = SimRecorder::new(42L)
  @test.assert_eq(rec.is_recording(), true)
  @test.assert_eq(rec.is_replaying(), false)
}

///|
test "trace_build" {
  let rec = SimRecorder::new(42L)
  let trace = rec.build_trace("ok")
  @test.assert_eq(trace.seed, 42L)
  @test.assert_eq(trace.result_summary, "ok")
}

///|
test "scenario_creation" {
  let s = new_scenario("test", 42L)
  @test.assert_eq(s.name, "test")
  @test.assert_eq(s.seed, 42L)
}
