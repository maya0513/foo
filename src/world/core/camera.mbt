///|
/// 三人称オービットカメラ（純ロジック）。向き（yaw/pitch）と距離（dist）は
/// プレイヤーの操作（マウスドラッグ・スワイプ・ホイール）だけで変わり、
/// 移動キーでは変わらない。位置はプレイヤー頭上の注視点を中心とした球面上で、
/// 指数平滑で滑らかに追従する。地形へのめり込みは y クランプで回避。
pub(all) struct Camera {
  yaw : Double // カメラが向く方位（atan2(dx,dz) 規約。yaw=0 で +z を見る）
  pitch : Double // 見下ろし角 [rad]。大きいほど上から見下ろす
  dist : Double // 注視点までの距離
  x : Double
  y : Double
  z : Double
  tx : Double // 注視点（プレイヤー頭上）
  ty : Double
  tz : Double
} derive(Eq)

///|
let min_pitch : Double = 0.02

///|
let max_pitch : Double = 1.35

///|
let min_dist : Double = 4.0

///|
let max_dist : Double = 18.0

///|
let default_pitch : Double = 0.30

///|
let default_dist : Double = 9.5

///|
/// 注視点のプレイヤー頭上オフセット。
let look_height : Double = 2.1

///|
/// yaw/pitch/dist から注視点を基準にした「望ましい」カメラ位置。
fn orbit_pos(
  tx : Double,
  ty : Double,
  tz : Double,
  yaw : Double,
  pitch : Double,
  dist : Double,
) -> (Double, Double, Double) {
  let cp = @math.cos(pitch)
  (
    tx - @math.sin(yaw) * cp * dist,
    ty + @math.sin(pitch) * dist,
    tz - @math.cos(yaw) * cp * dist,
  )
}

///|
/// スポーン直後のカメラ（プレイヤーの向きの後方に即セット、平滑なし）。
pub fn camera_init(spec : Spec, p : Player) -> Camera {
  let tx = p.x
  let ty = p.y + look_height
  let tz = p.z
  let (dx, dy, dz) = orbit_pos(tx, ty, tz, p.yaw, default_pitch, default_dist)
  let min_y = height_at(spec, dx, dz) + 0.8
  let cy = if dy < min_y { min_y } else { dy }
  {
    yaw: p.yaw,
    pitch: default_pitch,
    dist: default_dist,
    x: dx,
    y: cy,
    z: dz,
    tx,
    ty,
    tz,
  }
}

///|
/// 1 フレーム分カメラを進める。dyaw/dpitch はこのフレームの視点操作の回転量
/// [rad]、dzoom は距離の増分。向きは即時反映、位置は指数平滑で追従する。
pub fn step_camera(
  spec : Spec,
  cam : Camera,
  p : Player,
  dyaw : Double,
  dpitch : Double,
  dzoom : Double,
  dt : Double,
) -> Camera {
  let yaw = wrap_angle(cam.yaw + dyaw)
  let pitch = (cam.pitch + dpitch).clamp(min=min_pitch, max=max_pitch)
  let dist = (cam.dist + dzoom).clamp(min=min_dist, max=max_dist)
  let tx = p.x
  let ty = p.y + look_height
  let tz = p.z
  let (dx, dy, dz) = orbit_pos(tx, ty, tz, yaw, pitch, dist)
  // 位置追従。視点操作(dyaw/dpitch/dzoom)があった分は即時に反映し、
  // プレイヤー移動への追従だけを平滑化する（操作遅延を感じさせない）。
  let turned = dyaw != 0.0 || dpitch != 0.0 || dzoom != 0.0
  let s = if turned { 1.0 } else { 1.0 - @math.exp(-14.0 * dt) }
  let cx = cam.x + (dx - cam.x) * s
  let cz = cam.z + (dz - cam.z) * s
  let cy0 = cam.y + (dy - cam.y) * s
  // 地形へのめり込み回避
  let min_y = height_at(spec, cx, cz) + 0.8
  let cy = if cy0 < min_y { min_y } else { cy0 }
  { yaw, pitch, dist, x: cx, y: cy, z: cz, tx, ty, tz }
}

///|
/// 移動をカメラ相対にするための方位。オービットカメラでは yaw そのもの。
pub fn camera_yaw(cam : Camera) -> Double {
  cam.yaw
}
