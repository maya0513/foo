///|
/// ワールドの地形は「島状ハイトフィールド」。任意の座標 (x,z) の高さは
/// fBm ノイズ × 半径方向フォールオフで決まる純粋関数。中心は必ず陸、
/// 縁は必ず水没するので「島 + 周囲の湖水」が一つの式から同時に成立する。
///
/// height_at は three を一切知らない。表示側（src/world/scene.mbt）が
/// この関数から頂点配列を作る。core は世界の真実、three は表示キャッシュ。
pub fn height_at(spec : Spec, x : Double, z : Double) -> Double {
  let f = spec.base_freq
  // e ∈ [0,1] の起伏ノイズ
  let e = (
      fbm2(spec.seed, x * f, z * f, spec.octaves, spec.lacunarity, spec.gain) +
      1.0
    ) /
    2.0
  // 中心 0・縁 1 の正規化半径二乗。gradient は縁で 0、角でさらに負。
  let nx = x / spec.half_size
  let nz = z / spec.half_size
  let gradient = 1.0 - (nx * nx + nz * nz)
  let v = e * gradient - spec.shore
  v * spec.height_scale + spec.water_level
}

///|
/// 中央差分で傾き（勾配の大きさ）を求める。歩行可否・岩の着色に使う。
pub fn slope_at(spec : Spec, x : Double, z : Double) -> Double {
  let e = 0.75
  let dhx = height_at(spec, x + e, z) - height_at(spec, x - e, z)
  let dhz = height_at(spec, x, z + e) - height_at(spec, x, z - e)
  (dhx * dhx + dhz * dhz).sqrt() / (2.0 * e)
}

///|
/// 水面より下か。
pub fn is_underwater(spec : Spec, x : Double, z : Double) -> Bool {
  height_at(spec, x, z) < spec.water_level
}

///|
/// プレイヤーが立てる場所か。水際・急斜面・島の外周は不可。
pub fn is_walkable(spec : Spec, x : Double, z : Double) -> Bool {
  let h = height_at(spec, x, z)
  if h < spec.water_level + 0.35 {
    return false
  }
  let nx = x / spec.half_size
  let nz = z / spec.half_size
  if nx * nx + nz * nz > 0.94 * 0.94 {
    return false
  }
  slope_at(spec, x, z) < 2.4
}

///|
/// 地形メッシュの一辺あたり頂点数（segs + 1）。
pub fn grid_dim(spec : Spec) -> Int {
  spec.segs + 1
}

///|
/// 頂点 (i, j) のワールド座標 x。i,j ∈ [0, segs]。
fn grid_x(spec : Spec, i : Int) -> Double {
  let step = spec.half_size * 2.0 / spec.segs.to_double()
  -spec.half_size + i.to_double() * step
}

///|
/// 頂点位置配列（x, y, z を頂点順に平坦化）。行 j × 列 i、index = j*dim + i。
/// three の BufferGeometry position 属性へゼロコストで渡る Array[Double]。
pub fn terrain_positions(spec : Spec) -> Array[Double] {
  let dim = grid_dim(spec)
  let out : Array[Double] = []
  for j = 0; j < dim; j = j + 1 {
    let z = grid_x(spec, j)
    for i = 0; i < dim; i = i + 1 {
      let x = grid_x(spec, i)
      out.push(x)
      out.push(height_at(spec, x, z))
      out.push(z)
    }
  }
  out
}

///|
fn clamp01(v : Double) -> Double {
  v.clamp(min=0.0, max=1.0)
}

///|
fn fmax(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn mix3(
  a : (Double, Double, Double),
  b : (Double, Double, Double),
  t : Double,
) -> (Double, Double, Double) {
  (a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t, a.2 + (b.2 - a.2) * t)
}

///|
/// 高度・傾き・微小ノイズから頂点色（RGB, 各 [0,1]）を決める。
/// 水際は砂、中腹は 2 トーンの草、急斜面と高所は岩。パステル寄り。
pub fn color_at(
  spec : Spec,
  x : Double,
  z : Double,
  h : Double,
) -> (Double, Double, Double) {
  let sand = (0.91, 0.85, 0.66)
  let rock = (0.55, 0.52, 0.49)
  let gv = (value_noise2(spec.seed ^ 0x9e37U, x * 0.07, z * 0.07) + 1.0) / 2.0
  let grass = mix3((0.33, 0.53, 0.28), (0.55, 0.70, 0.38), gv)
  let mut col = grass
  if h < 1.8 {
    col = mix3(sand, grass, clamp01(h / 1.8))
  }
  let t = h / spec.height_scale
  let slope = slope_at(spec, x, z)
  let steepness = clamp01((slope - 1.0) / 1.3)
  let highness = clamp01((t - 0.52) / 0.28)
  let rock_w = fmax(steepness, highness)
  mix3(col, rock, rock_w)
}

///|
/// 頂点色配列（r, g, b を頂点順に平坦化）。terrain_positions と同じ順序。
pub fn terrain_colors(spec : Spec) -> Array[Double] {
  let dim = grid_dim(spec)
  let out : Array[Double] = []
  for j = 0; j < dim; j = j + 1 {
    let z = grid_x(spec, j)
    for i = 0; i < dim; i = i + 1 {
      let x = grid_x(spec, i)
      let h = height_at(spec, x, z)
      let (r, g, b) = color_at(spec, x, z, h)
      out.push(r)
      out.push(g)
      out.push(b)
    }
  }
  out
}

///|
/// 三角形インデックス配列（各セル 2 三角形 = 6 index）。上向き法線になる巻き順。
pub fn terrain_indices(spec : Spec) -> Array[Int] {
  let n = spec.segs
  let dim = n + 1
  let out : Array[Int] = []
  for j = 0; j < n; j = j + 1 {
    for i = 0; i < n; i = i + 1 {
      let a = j * dim + i
      let b = a + 1
      let c = a + dim
      let d = c + 1
      out.push(a)
      out.push(c)
      out.push(b)
      out.push(b)
      out.push(c)
      out.push(d)
    }
  }
  out
}
