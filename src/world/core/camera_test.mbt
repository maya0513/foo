///|
let cspec : @core.Spec = @core.default_spec()

///|
test "camera_init: プレイヤー後方 dist の位置・注視は頭上・地形の上" {
  let p = @core.player_spawn(cspec)
  let cam = @core.camera_init(cspec, p)
  let d = ((cam.x - cam.tx) * (cam.x - cam.tx) +
  (cam.y - cam.ty) * (cam.y - cam.ty) +
  (cam.z - cam.tz) * (cam.z - cam.tz)).sqrt()
  assert_true((d - cam.dist).abs() < 0.5)
  assert_true((cam.tx - p.x).abs() < 0.01)
  assert_true(cam.ty > p.y + 1.0)
  assert_true(cam.y >= @core.height_at(cspec, cam.x, cam.z) + 0.79)
}

///|
test "step_camera: dyaw で水平に回り、位置の方位が追従する" {
  let p = @core.player_spawn(cspec)
  let mut cam = @core.camera_init(cspec, p)
  let yaw0 = cam.yaw
  cam = @core.step_camera(cspec, cam, p, 0.5, 0.0, 0.0, 0.016)
  assert_true((cam.yaw - @core.wrap_angle(yaw0 + 0.5)).abs() < 1.0e-9)
  // 十分に回した後、カメラ位置の方位は yaw に一致する
  let mut t = 0.0
  while t < 2.0 {
    cam = @core.step_camera(cspec, cam, p, 0.0, 0.0, 0.0, 0.016)
    t = t + 0.016
  }
  let az = @math.atan2(cam.tx - cam.x, cam.tz - cam.z)
  assert_true(@core.wrap_angle(az - cam.yaw).abs() < 0.05)
}

///|
test "step_camera: pitch と dist はクランプされる" {
  let p = @core.player_spawn(cspec)
  let mut cam = @core.camera_init(cspec, p)
  cam = @core.step_camera(cspec, cam, p, 0.0, 100.0, 0.0, 0.016)
  assert_true(cam.pitch <= 1.35)
  cam = @core.step_camera(cspec, cam, p, 0.0, -100.0, 0.0, 0.016)
  assert_true(cam.pitch >= 0.02)
  cam = @core.step_camera(cspec, cam, p, 0.0, 0.0, 100.0, 0.016)
  assert_true(cam.dist <= 18.0)
  cam = @core.step_camera(cspec, cam, p, 0.0, 0.0, -100.0, 0.016)
  assert_true(cam.dist >= 4.0)
}

///|
test "step_camera: 入力なしで望ましい位置へ収束する" {
  let p = @core.player_spawn(cspec)
  let init = @core.camera_init(cspec, p)
  // わざと遠い位置から追従させる
  let mut cam : @core.Camera = {
    ..init,
    x: p.x + 40.0,
    y: p.y + 40.0,
    z: p.z + 40.0,
  }
  let mut t = 0.0
  while t < 3.0 {
    cam = @core.step_camera(cspec, cam, p, 0.0, 0.0, 0.0, 0.016)
    t = t + 0.016
  }
  let d = ((cam.x - p.x) * (cam.x - p.x) + (cam.z - p.z) * (cam.z - p.z)).sqrt()
  assert_true(d < cam.dist + 2.0)
  assert_true(d > 3.0)
}

///|
test "step_camera: 地形へめり込まない（y クランプ）" {
  let p = @core.player_spawn(cspec)
  let mut cam = @core.camera_init(cspec, p)
  let mut t = 0.0
  while t < 1.0 {
    cam = @core.step_camera(cspec, cam, p, 0.05, -0.01, 0.0, 0.016)
    assert_true(cam.y >= @core.height_at(cspec, cam.x, cam.z) + 0.79)
    t = t + 0.016
  }
}

///|
test "step_camera: 決定的" {
  let p = @core.player_spawn(cspec)
  let a = @core.step_camera(
    cspec,
    @core.camera_init(cspec, p),
    p,
    0.1,
    0.02,
    0.5,
    0.016,
  )
  let b = @core.step_camera(
    cspec,
    @core.camera_init(cspec, p),
    p,
    0.1,
    0.02,
    0.5,
    0.016,
  )
  assert_true(a == b)
}

///|
test "camera_yaw: カメラの方位そのものを返す（移動のカメラ相対化に使う）" {
  let p = @core.player_spawn(cspec)
  let cam = @core.camera_init(cspec, p)
  @debug.assert_eq(@core.camera_yaw(cam), cam.yaw)
}
