///|
/// プレイヤーの運動モデル（純ロジック）。加速は指数減衰でフレームレート非依存、
/// 移動は X/Z 軸を別々に試して壁ずり（斜面・水際に沿って滑る）、
/// y は常に地形高さに吸着する。
pub(all) struct Player {
  x : Double
  y : Double
  z : Double
  vx : Double
  vz : Double
  yaw : Double
} derive(Eq)

///|
/// 中心付近の歩ける地点をらせん状に探してスポーン地点を決める。
pub fn player_spawn(spec : Spec) -> Player {
  let mut r = 0.0
  while r < spec.half_size {
    let steps = if r < 1.0 { 1 } else { (r * 1.2).to_int() + 4 }
    for k = 0; k < steps; k = k + 1 {
      let a = k.to_double() / steps.to_double() * 2.0 * 3.141592653589793
      let x = @math.cos(a) * r
      let z = @math.sin(a) * r
      if is_walkable(spec, x, z) {
        return { x, y: height_at(spec, x, z), z, vx: 0.0, vz: 0.0, yaw: 0.0 }
      }
    }
    r = r + 2.0
  }
  { x: 0.0, y: height_at(spec, 0.0, 0.0), z: 0.0, vx: 0.0, vz: 0.0, yaw: 0.0 }
}

///|
/// 1 フレーム分プレイヤーを進める。
/// dir は正規化済みワールド水平方向、speed は最高速度 [m/s]、dt は秒。
/// cols は障害物（木・岩）の衝突円。地形と障害物の両方で移動を止める。
pub fn step_player(
  spec : Spec,
  p : Player,
  cols : Array[Collider],
  dir_x : Double,
  dir_z : Double,
  speed : Double,
  dt : Double,
) -> Player {
  let k = 11.0
  let smooth = 1.0 - @math.exp(-k * dt)
  let tvx = dir_x * speed
  let tvz = dir_z * speed
  let vx = p.vx + (tvx - p.vx) * smooth
  let vz = p.vz + (tvz - p.vz) * smooth
  // X を試す → だめなら止めて Z だけ滑らせる（壁ずり）
  let nx = p.x + vx * dt
  let (fx, fvx) = if passable(spec, cols, nx, p.z) {
    (nx, vx)
  } else {
    (p.x, 0.0)
  }
  let nz = p.z + vz * dt
  let (fz, fvz) = if passable(spec, cols, fx, nz) {
    (nz, vz)
  } else {
    (p.z, 0.0)
  }
  let y = height_at(spec, fx, fz)
  let sp2 = fvx * fvx + fvz * fvz
  let yaw = if sp2 > 1.0e-3 { @math.atan2(fvx, fvz) } else { p.yaw }
  { x: fx, y, z: fz, vx: fvx, vz: fvz, yaw }
}
