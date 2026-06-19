/// 确定性逻辑时钟，所有时间以纳秒（Int64）为单位。

pub struct SimClock {
  now : Int64
  rng : SimRng
  drift_ppm : Int64
}

pub fn SimClock::new(
  start_nanos : Int64,
  rng : SimRng,
  drift_ppm : Int64,
) -> SimClock {
  SimClock::{ now: start_nanos, rng, drift_ppm }
}

pub fn SimClock::zero(rng : SimRng) -> SimClock {
  SimClock::new(0L, rng, 0L)
}

/// 返回当前模拟时间。
pub fn SimClock::now(self : SimClock) -> Int64 {
  self.now
}

/// 时钟推进指定纳秒数。
pub fn SimClock::advance(self : SimClock, duration_nanos : Int64) -> SimClock {
  SimClock::{ ..self, now: self.now + duration_nanos }
}

/// 休眠（等价于 advance）。
pub fn SimClock::sleep(self : SimClock, duration_nanos : Int64) -> SimClock {
  self.advance(duration_nanos)
}

/// 跳转到指定时间，不允许回退。
pub fn SimClock::jump_to(
  self : SimClock,
  target_nanos : Int64,
) -> Result[SimClock, String] {
  if target_nanos < self.now {
    Err("不允许回退时间")
  } else {
    Ok(SimClock::{ ..self, now: target_nanos })
  }
}

/// 强制设置时间（绕过单调性检查）。
pub fn SimClock::force_set(self : SimClock, time_nanos : Int64) -> SimClock {
  SimClock::{ ..self, now: time_nanos }
}

// ─── 模拟瞬时值 ───────────────────────────────────────────────────────

pub struct SimInstant {
  nanos : Int64
}

pub fn SimInstant::from_nanos(nanos : Int64) -> SimInstant {
  SimInstant::{ nanos, }
}

pub fn SimInstant::nanos(self : SimInstant) -> Int64 {
  self.nanos
}

/// 计算两个瞬时值之间的时间差（self - earlier）。
pub fn SimInstant::duration_since(
  self : SimInstant,
  earlier : SimInstant,
) -> Int64 {
  self.nanos - earlier.nanos
}

/// 判断当前瞬时值是否在另一个之后。
pub fn SimInstant::after(self : SimInstant, other : SimInstant) -> Bool {
  self.nanos > other.nanos
}

/// 判断当前瞬时值是否在另一个之前。
pub fn SimInstant::before(self : SimInstant, other : SimInstant) -> Bool {
  self.nanos < other.nanos
}

/// 加上一段时长。
pub fn SimInstant::add(self : SimInstant, duration_nanos : Int64) -> SimInstant {
  SimInstant::from_nanos(self.nanos + duration_nanos)
}

/// 减去一段时长。
pub fn SimInstant::sub(self : SimInstant, duration_nanos : Int64) -> SimInstant {
  SimInstant::from_nanos(self.nanos - duration_nanos)
}
