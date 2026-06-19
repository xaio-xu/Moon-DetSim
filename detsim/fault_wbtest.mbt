test "存储故障_磁盘满拒绝写入" {
  let config = StorageFaultConfig::{ disk_full: true, corruption_probability: 0.0 }
  let rng = SimRng::new(42L)
  let (_, ok) = simulate_storage_fault(config, rng)
  @test.assert_eq(ok, false)
}

test "存储故障_正常写入" {
  let config = no_storage_faults()
  let rng = SimRng::new(42L)
  let (_, ok) = simulate_storage_fault(config, rng)
  @test.assert_eq(ok, true)
}

test "进程故障_高概率崩溃" {
  let config = ProcessFaultConfig::{ crash_probability_per_second: 1.0 }
  let rng = SimRng::new(42L)
  let (_, faults) = active_process_faults(config, rng)
  @test.assert_eq(faults.length(), 1)
}

test "进程故障_零概率无崩溃" {
  let config = no_process_faults()
  let rng = SimRng::new(42L)
  let (_, faults) = active_process_faults(config, rng)
  @test.assert_eq(faults.length(), 0)
}

test "时钟故障_漂移修正" {
  let config = ClockFaultConfig::{ drift_ppm: 100000L }
  let rng = SimRng::new(42L)
  let (_, time) = simulate_clock_fault(config, 1000000L, rng)
  @test.assert_eq(time > 1000000L, true)
}
