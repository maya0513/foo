///|
let spec : @core.Spec = @core.default_spec()

///|
test "height_at: 決定的" {
  @debug.assert_eq(
    @core.height_at(spec, 3.0, -7.0),
    @core.height_at(spec, 3.0, -7.0),
  )
}

///|
test "height_at: 島の縁は必ず水没する（ノイズに依らず）" {
  // 半径 0.99 上の 8 方向はすべて water_level 未満
  let r = spec.half_size * 0.99
  for k = 0; k < 8; k = k + 1 {
    let a = k.to_double() / 8.0 * 2.0 * 3.141592653589793
    let x = @math.cos(a) * r
    let z = @math.sin(a) * r
    assert_true(@core.height_at(spec, x, z) < spec.water_level)
  }
}

///|
test "height_at: 島には陸地が存在する（最高点は十分高い）" {
  let mut hi = -1000.0
  let n = 60
  for j = 0; j < n; j = j + 1 {
    for i = 0; i < n; i = i + 1 {
      let x = (i.to_double() / n.to_double() - 0.5) * spec.half_size * 1.6
      let z = (j.to_double() / n.to_double() - 0.5) * spec.half_size * 1.6
      let h = @core.height_at(spec, x, z)
      if h > hi {
        hi = h
      }
    }
  }
  assert_true(hi > 8.0)
}

///|
test "terrain_positions: 長さは 3 * (segs+1)^2、y は height_at と一致" {
  let dim = @core.grid_dim(spec)
  let pos = @core.terrain_positions(spec)
  @debug.assert_eq(pos.length(), 3 * dim * dim)
  // 数点で y が height_at と一致
  let step = spec.half_size * 2.0 / spec.segs.to_double()
  for s = 0; s < 5; s = s + 1 {
    let i = s * 17 % dim
    let j = s * 29 % dim
    let idx = (j * dim + i) * 3
    let x = -spec.half_size + i.to_double() * step
    let z = -spec.half_size + j.to_double() * step
    @debug.assert_eq(pos[idx + 1], @core.height_at(spec, x, z))
    @debug.assert_eq(pos[idx], x)
    @debug.assert_eq(pos[idx + 2], z)
  }
}

///|
test "terrain_colors: 長さは 3 * 頂点数、各成分 [0,1]" {
  let dim = @core.grid_dim(spec)
  let col = @core.terrain_colors(spec)
  @debug.assert_eq(col.length(), 3 * dim * dim)
  for i = 0; i < col.length(); i = i + 200 {
    assert_true(col[i] >= 0.0)
    assert_true(col[i] <= 1.0)
  }
}

///|
test "terrain_indices: 各セル 6 index、全て頂点範囲内" {
  let dim = @core.grid_dim(spec)
  let idx = @core.terrain_indices(spec)
  @debug.assert_eq(idx.length(), spec.segs * spec.segs * 6)
  let vcount = dim * dim
  for i = 0; i < idx.length(); i = i + 137 {
    assert_true(idx[i] >= 0)
    assert_true(idx[i] < vcount)
  }
}

///|
test "is_walkable: 深い水の上は歩けない・スポーン地点は歩ける" {
  let r = spec.half_size * 0.99
  assert_true(!@core.is_walkable(spec, r, 0.0))
  let p = @core.player_spawn(spec)
  assert_true(@core.is_walkable(spec, p.x, p.z))
}
