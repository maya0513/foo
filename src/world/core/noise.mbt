///|
/// 格子点の値 [-1,1]。値ノイズの基礎。
pub fn lattice_value(seed : UInt, xi : Int, zi : Int) -> Double {
  to_unit(hash2(seed, xi, zi)) * 2.0 - 1.0
}

///|
/// smoothstep 型のフェード曲線（一次微分が端点で 0）。
fn fade(t : Double) -> Double {
  t * t * (3.0 - 2.0 * t)
}

///|
fn lerp(a : Double, b : Double, t : Double) -> Double {
  a + (b - a) * t
}

///|
/// 2次元値ノイズ [-1,1]。格子点ハッシュ + 双線形補間。
pub fn value_noise2(seed : UInt, x : Double, z : Double) -> Double {
  let xf = x.floor()
  let zf = z.floor()
  let xi = xf.to_int()
  let zi = zf.to_int()
  let tx = fade(x - xf)
  let tz = fade(z - zf)
  let v00 = lattice_value(seed, xi, zi)
  let v10 = lattice_value(seed, xi + 1, zi)
  let v01 = lattice_value(seed, xi, zi + 1)
  let v11 = lattice_value(seed, xi + 1, zi + 1)
  lerp(lerp(v00, v10, tx), lerp(v01, v11, tx), tz)
}

///|
/// fBm（fractal Brownian motion）。オクターブ合成後に振幅合計で正規化し [-1,1] を保つ。
pub fn fbm2(
  seed : UInt,
  x : Double,
  z : Double,
  octaves : Int,
  lacunarity : Double,
  gain : Double,
) -> Double {
  let mut sum = 0.0
  let mut amp = 1.0
  let mut freq = 1.0
  let mut total = 0.0
  for i = 0; i < octaves; i = i + 1 {
    let octave_seed = seed + i.reinterpret_as_uint() * 0x9e3779b9
    sum = sum + value_noise2(octave_seed, x * freq, z * freq) * amp
    total = total + amp
    amp = amp * gain
    freq = freq * lacunarity
  }
  sum / total
}
