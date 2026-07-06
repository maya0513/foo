///|
/// 入力の純ロジック。副作用層（src/world/input.mbt）が集めた生のキー状態や
/// スティック値を、正規化されたカメラ相対の移動ベクトルに変換する。
/// ここに DOM もイベントも出てこない。

///|
/// キー押下状態 → 生の (strafe, forward)。strafe は右が +、forward は前が +。
pub fn keys_to_axes(
  up : Bool,
  down : Bool,
  left : Bool,
  right : Bool,
) -> (Double, Double) {
  let strafe = (if right { 1.0 } else { 0.0 }) - (if left { 1.0 } else { 0.0 })
  let forward = (if up { 1.0 } else { 0.0 }) - (if down { 1.0 } else { 0.0 })
  (strafe, forward)
}

///|
/// デッドゾーン適用（|v| < dz は 0、それ以外は再スケールして連続に）。
pub fn deadzone(v : Double, dz : Double) -> Double {
  let a = v.abs()
  if a < dz {
    0.0
  } else {
    let s = (a - dz) / (1.0 - dz)
    if v < 0.0 {
      -s
    } else {
      s
    }
  }
}

///|
/// 2 次元スティック入力をデッドゾーン処理し、長さ 1 にクランプ。
pub fn stick_axes(sx : Double, sz : Double, dz : Double) -> (Double, Double) {
  let len = (sx * sx + sz * sz).sqrt()
  if len < dz {
    return (0.0, 0.0)
  }
  let scaled = deadzone(len, dz)
  let clamped = if scaled > 1.0 { 1.0 } else { scaled }
  (sx / len * clamped, sz / len * clamped)
}

///|
/// カメラ相対の (strafe, forward) を、カメラの yaw で回してワールドの
/// 水平移動方向 (dx, dz) にする。長さは 1 以下にクランプ。
/// yaw はカメラが向く方位（atan2(dx, dz) 規約）。yaw=0 で forward が +z。
pub fn move_direction(
  strafe : Double,
  forward : Double,
  yaw : Double,
) -> (Double, Double) {
  let len = (strafe * strafe + forward * forward).sqrt()
  let (sx, fz) = if len > 1.0 {
    (strafe / len, forward / len)
  } else {
    (strafe, forward)
  }
  let c = @math.cos(yaw)
  let s = @math.sin(yaw)
  // forward(+) をカメラ前方 (sin yaw, cos yaw)、strafe(+) を右 (cos yaw, -sin yaw) へ
  let dx = fz * s + sx * c
  let dz = fz * c - sx * s
  (dx, dz)
}

///|
/// 角度を (-π, π] に正規化する。
pub fn wrap_angle(a : Double) -> Double {
  let two_pi = 3.141592653589793 * 2.0
  let mut r = a
  while r > 3.141592653589793 {
    r = r - two_pi
  }
  while r <= -3.141592653589793 {
    r = r + two_pi
  }
  r
}
