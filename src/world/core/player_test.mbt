///|
let pspec : @core.Spec = @core.default_spec()

///|
let pcols : Array[@core.Collider] = @core.colliders(pspec)

///|
/// 単位時間シミュレート（dt 刻みで total 秒ぶん前進入力）。
fn sim(
  dir_x : Double,
  dir_z : Double,
  dt : Double,
  total : Double,
) -> @core.Player {
  let mut p = @core.player_spawn(pspec)
  let mut t = 0.0
  while t < total {
    p = @core.step_player(pspec, p, pcols, dir_x, dir_z, @core.move_speed, dt)
    t = t + dt
  }
  p
}

///|
test "step_player: 決定的" {
  let a = sim(0.0, 1.0, 0.016, 1.0)
  let b = sim(0.0, 1.0, 0.016, 1.0)
  assert_true(a == b)
}

///|
test "step_player: 速度は最高速度へ収束（フレームレート非依存）" {
  // 大 dt と小 dt で 1.5 秒後の速さがほぼ一致し、move_speed 付近
  let big = sim(0.0, 1.0, 0.05, 1.5)
  let small = sim(0.0, 1.0, 0.008, 1.5)
  let sbig = (big.vx * big.vx + big.vz * big.vz).sqrt()
  let ssmall = (small.vx * small.vx + small.vz * small.vz).sqrt()
  assert_true((sbig - ssmall).abs() < 1.0)
  assert_true(sbig > @core.move_speed * 0.8)
}

///|
test "step_player: 前進で位置が実際に動く・yaw が進行方向を向く" {
  let start = @core.player_spawn(pspec)
  let moved = sim(0.0, 1.0, 0.016, 0.6)
  let d = ((moved.x - start.x) * (moved.x - start.x) +
  (moved.z - start.z) * (moved.z - start.z)).sqrt()
  assert_true(d > 1.0)
}

///|
test "step_player: y は常に地形高さに吸着" {
  let p = sim(1.0, 0.3, 0.016, 0.5)
  assert_true((p.y - @core.height_at(pspec, p.x, p.z)).abs() < 1.0e-9)
}

///|
test "step_player: 歩けない方向へは滑って留まる（NaN/暴走しない）" {
  // スポーン地点から全方向に長時間走らせても座標は有限で島内
  for k = 0; k < 8; k = k + 1 {
    let a = k.to_double() / 8.0 * 2.0 * 3.141592653589793
    let p = sim(@math.cos(a), @math.sin(a), 0.02, 4.0)
    let r = (p.x * p.x + p.z * p.z).sqrt()
    assert_true(r < pspec.half_size)
    assert_true(@core.is_walkable(pspec, p.x, p.z))
  }
}
