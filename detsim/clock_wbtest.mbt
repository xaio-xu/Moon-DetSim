///|
test "clock_initial_time" {
  let rng = SimRng::new(42L)
  let clock = SimClock::new(1000L, rng, 0L)
  @test.assert_eq(clock.now(), 1000L)
}

///|
test "clock_zero" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  @test.assert_eq(clock.now(), 0L)
}

///|
test "clock_advance" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng).advance(1000L)
  @test.assert_eq(clock.now(), 1000L)
}

///|
test "clock_deterministic" {
  let rng1 = SimRng::new(42L)
  let rng2 = SimRng::new(42L)
  let clock1 = SimClock::zero(rng1).advance(100L).advance(200L)
  let clock2 = SimClock::zero(rng2).advance(100L).advance(200L)
  @test.assert_eq(clock1.now(), clock2.now())
}

///|
test "clock_jump_forward" {
  let rng = SimRng::new(42L)
  let clock = SimClock::zero(rng)
  let result = clock.jump_to(10_000L)
  match result {
    Ok(c) => @test.assert_eq(c.now(), 10_000L)
    Err(_) => abort("Jump forward should succeed")
  }
}

///|
test "clock_jump_backward_fails" {
  let rng = SimRng::new(42L)
  let clock = SimClock::new(10_000L, rng, 0L)
  let result = clock.jump_to(5_000L)
  match result {
    Ok(_) => abort("Should fail")
    Err(_) => ()
  }
}

///|
test "instant_comparison" {
  let t1 = SimInstant::from_nanos(100L)
  let t2 = SimInstant::from_nanos(200L)
  @test.assert_eq(t1.before(t2), true)
  @test.assert_eq(t2.after(t1), true)
}
