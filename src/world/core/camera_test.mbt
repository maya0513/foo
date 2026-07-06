///|
let cspec : @core.Spec = @core.default_spec()

///|
test "camera_init: プレイヤー後方に構え、地形上にある" {
  let p = @core.player_spawn(cspec)
  let cam = @core.camera_init(cspec, p)
  assert_true(cam.y >= @core.height_at(cspec, cam.x, cam.z) + 1.19)
  // 注視点はプレイヤー付近
  assert_true((cam.tx - p.x).abs() < 0.01)
}

///|
test "step_camera: 望ましい位置へ収束する" {
  let p = @core.player_spawn(cspec)
  // わざと遠いカメラから始めて追従させる
  let mut cam : @core.Camera = {
    x: p.x + 40.0,
    y: p.y + 40.0,
    z: p.z + 40.0,
    tx: p.x,
    ty: p.y,
    tz: p.z,
  }
  let mut t = 0.0
  while t < 3.0 {
    cam = @core.step_camera(cspec, cam, p, 0.016)
    t = t + 0.016
  }
  // 収束後はプレイヤーから概ね cam_dist 程度の距離
  let d = ((cam.x - p.x) * (cam.x - p.x) + (cam.z - p.z) * (cam.z - p.z)).sqrt()
  assert_true(d < 14.0)
  assert_true(d > 4.0)
}

///|
test "step_camera: 地形へめり込まない（y クランプ）" {
  let p = @core.player_spawn(cspec)
  let mut cam = @core.camera_init(cspec, p)
  let mut t = 0.0
  while t < 1.0 {
    cam = @core.step_camera(cspec, cam, p, 0.016)
    assert_true(cam.y >= @core.height_at(cspec, cam.x, cam.z) + 1.19)
    t = t + 0.016
  }
}

///|
test "step_camera: 決定的" {
  let p = @core.player_spawn(cspec)
  let a = @core.step_camera(cspec, @core.camera_init(cspec, p), p, 0.016)
  let b = @core.step_camera(cspec, @core.camera_init(cspec, p), p, 0.016)
  assert_true(a == b)
}
