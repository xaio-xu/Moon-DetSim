///|
test "rng_same_seed_deterministic" {
  let rng1 = SimRng::new(42L)
  let rng2 = SimRng::new(42L)
  let (_, val1) = rng1.next_int64()
  let (_, val2) = rng2.next_int64()
  @test.assert_eq(val1, val2)
}

///|
test "rng_different_seeds" {
  let rng1 = SimRng::new(42L)
  let rng2 = SimRng::new(99L)
  let (_, val1) = rng1.next_int64()
  let (_, val2) = rng2.next_int64()
  @test.assert_eq(val1 != val2, true)
}

///|
test "rng_sequence_reproducible" {
  let mut r1 = SimRng::new(777L)
  let mut r2 = SimRng::new(777L)
  for i = 0; i < 100; i = i + 1 {
    let (next1, v1) = r1.next_int64()
    let (next2, v2) = r2.next_int64()
    r1 = next1
    r2 = next2
    @test.assert_eq(v1, v2)
  }
}

///|
test "rng_next_between_range" {
  let mut r = SimRng::new(42L)
  for i = 0; i < 100; i = i + 1 {
    let (next, val) = r.next_between(10L, 20L)
    r = next
    @test.assert_eq(val >= 10L, true)
    @test.assert_eq(val <= 20L, true)
  }
}

///|
test "rng_next_double_range" {
  let mut r = SimRng::new(42L)
  for i = 0; i < 100; i = i + 1 {
    let (next, val) = r.next_double()
    r = next
    @test.assert_eq(val >= 0.0, true)
    @test.assert_eq(val < 1.0, true)
  }
}

///|
test "rng_child_deterministic" {
  let rng1 = SimRng::new(42L)
  let rng2 = SimRng::new(42L)
  let child1 = rng1.child("send")
  let child2 = rng2.child("send")
  let (_, val1) = child1.next_int64()
  let (_, val2) = child2.next_int64()
  @test.assert_eq(val1, val2)
}

///|
test "rng_original_seed" {
  let rng = SimRng::new(777L)
  @test.assert_eq(rng.original_seed(), 777L)
}
