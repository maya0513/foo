///|
/// 木や岩の配置（純ロジック）。決定的ハッシュで候補点を格子状に過剰生成し、
/// 水没・急斜面・外周・高度帯・密度マスクでふるいにかける。
/// 同じ spec からは常に同じ森が生える。
pub(all) struct Placement {
  x : Double
  y : Double
  z : Double
  rot : Double
  scale : Double
  variant : Int
} derive(Eq)

///|
/// 木の群生。中腹帯（水際より上・岩場より下）に、ノイズ密度マスクで固まって生える。
pub fn scatter_trees(spec : Spec) -> Array[Placement] {
  let out : Array[Placement] = []
  let n = 64
  let size = spec.half_size * 2.0
  let cell = size / n.to_double()
  let salt = 0x54524545U // "TREE"
  // スポーン周辺は開けた広場にする（降り立った瞬間に視界と行き先が分かるように）
  let spawn = player_spawn(spec)
  let clearing = 12.0
  for j = 0; j < n; j = j + 1 {
    for i = 0; i < n; i = i + 1 {
      let h0 = hash3(spec.seed ^ salt, i, j, 0)
      let jx = to_unit(h0)
      let jz = to_unit(hash3(spec.seed ^ salt, i, j, 1))
      let x = -spec.half_size + (i.to_double() + jx) * cell
      let z = -spec.half_size + (j.to_double() + jz) * cell
      if !is_walkable(spec, x, z) {
        continue
      }
      let sdx = x - spawn.x
      let sdz = z - spawn.z
      if sdx * sdx + sdz * sdz < clearing * clearing {
        continue
      }
      let h = height_at(spec, x, z)
      if h < 1.6 || h > spec.height_scale * 0.62 {
        continue
      }
      if slope_at(spec, x, z) > 1.6 {
        continue
      }
      // 群生: 低周波ノイズが高い場所だけ森になり、低い場所は草原として開ける
      let density = (
          value_noise2(spec.seed ^ 0xABCDU, x * 0.04, z * 0.04) + 1.0
        ) /
        2.0
      if density < 0.42 {
        continue
      }
      let accept = to_unit(hash3(spec.seed ^ salt, i, j, 2))
      if accept > density * 0.9 {
        continue
      }
      let variant = (hash3(spec.seed ^ salt, i, j, 3) % 3U).reinterpret_as_int()
      let rot = to_unit(hash3(spec.seed ^ salt, i, j, 4)) *
        2.0 *
        3.141592653589793
      let scale = 0.8 + to_unit(hash3(spec.seed ^ salt, i, j, 5)) * 0.7
      out.push({ x, y: h, z, rot, scale, variant })
    }
  }
  out
}

///|
/// 岩。木より広い高度帯にまばらに散らす。急斜面も許容。
pub fn scatter_rocks(spec : Spec) -> Array[Placement] {
  let out : Array[Placement] = []
  let n = 40
  let size = spec.half_size * 2.0
  let cell = size / n.to_double()
  let salt = 0x524f434bU // "ROCK"
  for j = 0; j < n; j = j + 1 {
    for i = 0; i < n; i = i + 1 {
      let jx = to_unit(hash3(spec.seed ^ salt, i, j, 0))
      let jz = to_unit(hash3(spec.seed ^ salt, i, j, 1))
      let x = -spec.half_size + (i.to_double() + jx) * cell
      let z = -spec.half_size + (j.to_double() + jz) * cell
      let h = height_at(spec, x, z)
      if h < spec.water_level + 0.6 {
        continue
      }
      let nx = x / spec.half_size
      let nz = z / spec.half_size
      if nx * nx + nz * nz > 0.9 * 0.9 {
        continue
      }
      let accept = to_unit(hash3(spec.seed ^ salt, i, j, 2))
      if accept > 0.13 {
        continue
      }
      let variant = (hash3(spec.seed ^ salt, i, j, 3) % 2U).reinterpret_as_int()
      let rot = to_unit(hash3(spec.seed ^ salt, i, j, 4)) *
        2.0 *
        3.141592653589793
      let scale = 0.35 + to_unit(hash3(spec.seed ^ salt, i, j, 5)) * 0.75
      out.push({ x, y: h, z, rot, scale, variant })
    }
  }
  out
}
