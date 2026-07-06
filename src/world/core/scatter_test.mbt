///|
let sspec : @core.Spec = @core.default_spec()

///|
test "scatter_trees: 決定的（同じ spec は同じ森）" {
  let a = @core.scatter_trees(sspec)
  let b = @core.scatter_trees(sspec)
  @debug.assert_eq(a.length(), b.length())
  assert_true(a.length() > 0)
  for i = 0; i < a.length(); i = i + 1 {
    assert_true(a[i] == b[i])
  }
}

///|
test "scatter_trees: すべて歩ける中腹帯に立ち、y は地形に一致" {
  let trees = @core.scatter_trees(sspec)
  for t in trees {
    assert_true(@core.is_walkable(sspec, t.x, t.z))
    assert_true(t.y >= 1.6)
    assert_true((t.y - @core.height_at(sspec, t.x, t.z)).abs() < 1.0e-9)
    assert_true(t.variant >= 0 && t.variant < 3)
    assert_true(t.scale > 0.0)
  }
}

///|
test "scatter_trees: スポーン周辺は開けている（クリアリング）" {
  let spawn = @core.player_spawn(sspec)
  for t in @core.scatter_trees(sspec) {
    let dx = t.x - spawn.x
    let dz = t.z - spawn.z
    assert_true((dx * dx + dz * dz).sqrt() >= 10.0)
  }
}

///|
test "scatter_rocks: 決定的・水没しない・島内" {
  let a = @core.scatter_rocks(sspec)
  let b = @core.scatter_rocks(sspec)
  @debug.assert_eq(a.length(), b.length())
  assert_true(a.length() > 0)
  for r in a {
    assert_true(!@core.is_underwater(sspec, r.x, r.z))
    let rad = (r.x * r.x + r.z * r.z).sqrt()
    assert_true(rad < sspec.half_size)
    assert_true(r.variant >= 0 && r.variant < 2)
  }
}
