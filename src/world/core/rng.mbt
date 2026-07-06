///|
/// 決定的な無状態ハッシュ。ワールド生成のあらゆる乱数の源。
/// 状態を持たないので同じ (seed, 座標) からは常に同じ世界が生まれる。
fn mix(x : UInt) -> UInt {
  let mut h = x
  h = (h ^ (h >> 16)) * 0x7feb352d
  h = (h ^ (h >> 15)) * 0x846ca68b
  h ^ (h >> 16)
}

///|
pub fn hash2(seed : UInt, xi : Int, zi : Int) -> UInt {
  mix(
    seed ^
    mix(xi.reinterpret_as_uint() * 0x9e3779b9) ^
    mix(zi.reinterpret_as_uint() * 0x85ebca6b),
  )
}

///|
pub fn hash3(seed : UInt, xi : Int, zi : Int, k : Int) -> UInt {
  mix(hash2(seed, xi, zi) ^ mix(k.reinterpret_as_uint() * 0xc2b2ae35))
}

///|
/// ハッシュ値を [0,1) の Double に写す。
pub fn to_unit(h : UInt) -> Double {
  (h >> 8).reinterpret_as_int().to_double() / 16777216.0
}
