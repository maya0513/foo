///|
let xspec : @core.Spec = @core.default_spec()

///|
test "colliders: 決定的で、木と岩の総数だけ円がある" {
  let a = @core.colliders(xspec)
  let b = @core.colliders(xspec)
  @debug.assert_eq(a.length(), b.length())
  let expected = @core.scatter_trees(xspec).length() +
    @core.scatter_rocks(xspec).length()
  @debug.assert_eq(a.length(), expected)
  assert_true(a.length() > 0)
  for c in a {
    assert_true(c.radius > 0.0)
  }
}

///|
test "blocked: 障害物の中心は塞がれ、遠方は通れる" {
  let cols = @core.colliders(xspec)
  let c = cols[0]
  assert_true(@core.blocked(cols, c.x, c.z))
  // 島外の遠方には障害物が無い
  assert_true(!@core.blocked(cols, 1.0e6, 1.0e6))
}

///|
test "blocked: 円の外周ぎりぎり外は通れる" {
  let cols = @core.colliders(xspec)
  let c = cols[0]
  // 中心から radius + player_radius + 余白 だけ離れれば通れる
  let d = c.radius + @core.player_radius + 0.2
  assert_true(!@core.blocked(cols, c.x + d, c.z))
}

///|
/// テスト用に、周囲が歩ける（地形が塞いでいない）木の衝突円を1つ選ぶ。
fn pick_free_collider() -> @core.Collider {
  let cols = @core.colliders(xspec)
  for c in cols {
    let approach = c.x + c.radius + @core.player_radius + 0.5
    if @core.is_walkable(xspec, c.x, c.z) &&
      @core.is_walkable(xspec, approach, c.z) {
      return c
    }
  }
  cols[0]
}

///|
test "step_player: 障害物へ直進しても中へめり込まない" {
  let c = pick_free_collider()
  let cols = @core.colliders(xspec)
  let start_x = c.x + c.radius + @core.player_radius + 0.4
  let mut p : @core.Player = {
    x: start_x,
    y: @core.height_at(xspec, start_x, c.z),
    z: c.z,
    vx: 0.0,
    vz: 0.0,
    yaw: 0.0,
  }
  // 障害物の中心へ向かって（-x）突進し続ける
  let mut t = 0.0
  while t < 2.0 {
    p = @core.step_player(xspec, p, cols, -1.0, 0.0, @core.move_speed, 0.016)
    // プレイヤー中心が障害物の内側へ入り込んでいないこと
    let d = ((p.x - c.x) * (p.x - c.x) + (p.z - c.z) * (p.z - c.z)).sqrt()
    assert_true(d >= c.radius)
    t = t + 0.016
  }
}
