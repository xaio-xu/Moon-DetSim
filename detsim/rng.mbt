/// 确定性层级种子随机数生成器，基于 SplitMix64 算法。

pub struct SimRng {
  state : Int64
  seed : Int64
}

/// 从种子创建新的 SimRng。
pub fn SimRng::new(seed : Int64) -> SimRng {
  SimRng::{ state: splitmix64_next(seed), seed }
}

/// 生成下一个 Int64 并返回更新后的 RNG。
pub fn SimRng::next_int64(self : SimRng) -> (SimRng, Int64) {
  let val = splitmix64_next(self.state)
  let next_state = splitmix64_next(val)
  (SimRng::{ ..self, state: next_state }, val)
}

/// 生成 [lo, hi] 范围内的随机 Int64。
pub fn SimRng::next_between(
  self : SimRng,
  lo : Int64,
  hi : Int64,
) -> (SimRng, Int64) {
  let (rng, val) = self.next_int64()
  let range = hi - lo + 1L
  if range <= 0L {
    (rng, val)
  } else {
    let result = lo + (val & (range - 1L))
    (rng, result)
  }
}

/// 生成 [0.0, 1.0) 范围内的随机 Double。
pub fn SimRng::next_double(self : SimRng) -> (SimRng, Double) {
  let (rng, val) = self.next_int64()
  let bits = val.reinterpret_as_uint64() >> 11
  let d = bits.to_double() / 9007199254740992.0
  (rng, d)
}

/// 生成随机 Bool。
pub fn SimRng::next_bool(self : SimRng) -> (SimRng, Bool) {
  let (rng, val) = self.next_int64()
  (rng, (val & 1L) == 1L)
}

/// 为命名子操作创建子 RNG，确保子操作的随机序列独立于父序列。
pub fn SimRng::child(self : SimRng, name : String) -> SimRng {
  let hash = hash_string(self.state, name)
  SimRng::new(hash)
}

/// 返回原始种子（用于调试和回放）。
pub fn SimRng::original_seed(self : SimRng) -> Int64 {
  self.seed
}

/// SplitMix64 单步迭代。
fn splitmix64_next(state : Int64) -> Int64 {
  let mut z = state + 0x9E3779B97F4A7C15L
  z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9L
  z = (z ^ (z >> 27)) * 0x94D049BB133111EBL
  z ^ (z >> 31)
}

/// FNV-1a 风格字符串哈希，用于派生种子。
fn hash_string(seed : Int64, s : String) -> Int64 {
  let mut hash : Int64 = seed ^ 0xCBF29CE484222325L
  for i = 0; i < s.length(); i = i + 1 {
    hash = hash ^ s[i].to_int64()
    hash = hash * 0x100000001B3L
  }
  hash
}
