///|
/// 三人称追従カメラ（純ロジック）。プレイヤーの後方・斜め上に位置し、
/// 位置も注視点も指数平滑で滑らかに追う。地形へのめり込みは y クランプで回避。
pub(all) struct Camera {
  x : Double
  y : Double
  z : Double
  tx : Double
  ty : Double
  tz : Double
} derive(Eq)

///|
/// カメラ距離・高さ・注視の頭上オフセット。
let cam_dist : Double = 9.0

///|
let cam_height : Double = 4.4

///|
let look_height : Double = 1.6

///|
/// プレイヤーの yaw から見た「望ましい」カメラ位置。
fn desired_pos(p : Player) -> (Double, Double, Double) {
  let dx = p.x - @math.sin(p.yaw) * cam_dist
  let dz = p.z - @math.cos(p.yaw) * cam_dist
  let dy = p.y + cam_height
  (dx, dy, dz)
}

///|
/// スポーン直後のカメラ（望ましい位置に即セット、平滑なし）。
pub fn camera_init(spec : Spec, p : Player) -> Camera {
  let (dx, dy, dz) = desired_pos(p)
  let min_y = height_at(spec, dx, dz) + 1.2
  let cy = if dy < min_y { min_y } else { dy }
  { x: dx, y: cy, z: dz, tx: p.x, ty: p.y + look_height, tz: p.z }
}

///|
/// 1 フレーム分カメラを追従させる。
pub fn step_camera(
  spec : Spec,
  cam : Camera,
  p : Player,
  dt : Double,
) -> Camera {
  let (dx, dy, dz) = desired_pos(p)
  let s = 1.0 - @math.exp(-7.0 * dt)
  let cx = cam.x + (dx - cam.x) * s
  let cz = cam.z + (dz - cam.z) * s
  let cy0 = cam.y + (dy - cam.y) * s
  // 地形へのめり込み回避
  let min_y = height_at(spec, cx, cz) + 1.2
  let cy = if cy0 < min_y { min_y } else { cy0 }
  let ts = 1.0 - @math.exp(-10.0 * dt)
  let tx = cam.tx + (p.x - cam.tx) * ts
  let ty = cam.ty + (p.y + look_height - cam.ty) * ts
  let tz = cam.tz + (p.z - cam.tz) * ts
  { x: cx, y: cy, z: cz, tx, ty, tz }
}

///|
/// カメラが向く方位（水平面）。移動をカメラ相対にするために使う。
pub fn camera_yaw(cam : Camera, p : Player) -> Double {
  @math.atan2(p.x - cam.x, p.z - cam.z)
}
