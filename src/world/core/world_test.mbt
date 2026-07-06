///|
let wspec : @core.Spec = @core.default_spec()

///|
let wcols : Array[@core.Collider] = @core.colliders(wspec)

///|
test "init_game: スポーンは歩ける・カメラは後方・時刻 0" {
  let g = @core.init_game(wspec)
  assert_true(@core.is_walkable(wspec, g.player.x, g.player.z))
  @debug.assert_eq(g.time, 0.0)
}

///|
test "step_game: 時刻が dt ぶん進む・決定的" {
  let g0 = @core.init_game(wspec)
  let g1 = @core.step_game(wspec, g0, wcols, 0.0, 1.0, 0.0, 0.0, 0.0, 0.016)
  @debug.assert_eq(g1.time, 0.016)
  let g1b = @core.step_game(wspec, g0, wcols, 0.0, 1.0, 0.0, 0.0, 0.0, 0.016)
  assert_true(g1 == g1b)
}

///|
test "step_game: 前進入力で位置が動く" {
  let mut g = @core.init_game(wspec)
  let start = g.player
  let mut t = 0.0
  while t < 0.8 {
    g = @core.step_game(wspec, g, wcols, 0.0, 1.0, 0.0, 0.0, 0.0, 0.016)
    t = t + 0.016
  }
  let d = ((g.player.x - start.x) * (g.player.x - start.x) +
  (g.player.z - start.z) * (g.player.z - start.z)).sqrt()
  assert_true(d > 1.0)
}

///|
test "step_game: 視点操作だけではプレイヤーは動かない・移動ではカメラの向きが変わらない" {
  let mut g = @core.init_game(wspec)
  let start = g.player
  let mut t = 0.0
  while t < 0.5 {
    g = @core.step_game(wspec, g, wcols, 0.0, 0.0, 0.05, 0.01, 0.0, 0.016)
    t = t + 0.016
  }
  assert_true((g.player.x - start.x).abs() < 0.01)
  assert_true((g.player.z - start.z).abs() < 0.01)
  // 逆に、移動入力ではカメラの yaw/pitch は変わらない
  let yaw0 = g.camera.yaw
  let pitch0 = g.camera.pitch
  let mut t2 = 0.0
  while t2 < 0.5 {
    g = @core.step_game(wspec, g, wcols, 1.0, 1.0, 0.0, 0.0, 0.0, 0.016)
    t2 = t2 + 0.016
  }
  @debug.assert_eq(g.camera.yaw, yaw0)
  @debug.assert_eq(g.camera.pitch, pitch0)
}

///|
test "step_game: 入力なしなら静止したまま" {
  let mut g = @core.init_game(wspec)
  let start = g.player
  let mut t = 0.0
  while t < 0.5 {
    g = @core.step_game(wspec, g, wcols, 0.0, 0.0, 0.0, 0.0, 0.0, 0.016)
    t = t + 0.016
  }
  assert_true((g.player.x - start.x).abs() < 0.05)
  assert_true((g.player.z - start.z).abs() < 0.05)
}
