///|
test "keys_to_axes: 押下がベクトルになる" {
  @debug.assert_eq(@core.keys_to_axes(true, false, false, false), (0.0, 1.0))
  @debug.assert_eq(@core.keys_to_axes(false, true, false, false), (0.0, -1.0))
  @debug.assert_eq(@core.keys_to_axes(false, false, false, true), (1.0, 0.0))
  @debug.assert_eq(@core.keys_to_axes(true, true, true, true), (0.0, 0.0))
}

///|
test "deadzone: 閾値内は 0、外は連続" {
  @debug.assert_eq(@core.deadzone(0.1, 0.15), 0.0)
  @debug.assert_eq(@core.deadzone(0.15, 0.15), 0.0)
  assert_true(@core.deadzone(1.0, 0.15) > 0.99)
  assert_true(@core.deadzone(-1.0, 0.15) < -0.99)
}

///|
test "stick_axes: 長さ 1 にクランプ、デッドゾーン内は 0" {
  let (x, z) = @core.stick_axes(3.0, 4.0, 0.15)
  let len = (x * x + z * z).sqrt()
  assert_true(len <= 1.0001)
  assert_true(len > 0.99)
  @debug.assert_eq(@core.stick_axes(0.05, 0.05, 0.15), (0.0, 0.0))
}

///|
test "move_direction: yaw=0 は恒等、長さ保存、回転で長さ不変" {
  let (dx, dz) = @core.move_direction(0.0, 1.0, 0.0)
  assert_true((dx - 0.0).abs() < 1.0e-9)
  assert_true((dz - 1.0).abs() < 1.0e-9)
  // yaw=π/2 で前進が別軸へ、長さは 1 のまま
  let (ex, ez) = @core.move_direction(0.0, 1.0, 3.141592653589793 / 2.0)
  let len = (ex * ex + ez * ez).sqrt()
  assert_true((len - 1.0).abs() < 1.0e-9)
  assert_true(ex.abs() > 0.99)
}

///|
test "move_direction: strafe 右は画面の右（三次元は右手系なので +z を向くとき -x）" {
  // カメラが +z を向く（yaw=0）とき、画面の右は -x 方向。
  let (dx, dz) = @core.move_direction(1.0, 0.0, 0.0)
  assert_true((dx - -1.0).abs() < 1.0e-9)
  assert_true(dz.abs() < 1.0e-9)
  // カメラが +x を向く（yaw=π/2）とき、画面の右は +z 方向。
  let (ex, ez) = @core.move_direction(1.0, 0.0, 3.141592653589793 / 2.0)
  assert_true(ex.abs() < 1.0e-9)
  assert_true((ez - 1.0).abs() < 1.0e-9)
}

///|
test "move_direction: 斜め入力も長さ 1 以下に正規化" {
  let (dx, dz) = @core.move_direction(1.0, 1.0, 0.0)
  let len = (dx * dx + dz * dz).sqrt()
  assert_true(len <= 1.0001)
}

///|
test "wrap_angle: (-π, π] に収める" {
  assert_true(
    (@core.wrap_angle(3.141592653589793 * 3.0) - 3.141592653589793).abs() <
    1.0e-9,
  )
  assert_true(@core.wrap_angle(0.0) == 0.0)
  assert_true(
    @core.wrap_angle(-3.141592653589793 * 2.5).abs() <= 3.141592653589793,
  )
}
