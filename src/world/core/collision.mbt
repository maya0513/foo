///|
/// オブジェクトの当たり判定（純ロジック）。木の幹と岩を水平面上の円として持ち、
/// プレイヤーの円と重なったら「塞がれている」とみなす。spec から決定的に導出し、
/// 表示（scene.mbt）と同じ scatter を使うので、見た目と当たり判定が一致する。
pub(all) struct Collider {
  x : Double
  z : Double
  radius : Double
} derive(Eq)

///|
/// プレイヤーの当たり判定半径 [m]（小柄な胴に合わせた値）。
pub let player_radius : Double = 0.35

///|
/// spec から全障害物の衝突円を一度だけ構築する（木の幹・岩）。
/// 半径は表示スケールに比例させ、幹や岩の見た目の太さに合わせる。
pub fn colliders(spec : Spec) -> Array[Collider] {
  let out : Array[Collider] = []
  for t in scatter_trees(spec) {
    out.push({ x: t.x, z: t.z, radius: 0.42 * t.scale })
  }
  for r in scatter_rocks(spec) {
    out.push({ x: r.x, z: r.z, radius: 0.82 * r.scale })
  }
  out
}

///|
/// プレイヤー中心 (x,z) がいずれかの障害物円と重なるか。
pub fn blocked(cols : Array[Collider], x : Double, z : Double) -> Bool {
  for c in cols {
    let dx = x - c.x
    let dz = z - c.z
    let rr = c.radius + player_radius
    if dx * dx + dz * dz < rr * rr {
      return true
    }
  }
  false
}

///|
/// プレイヤーがその地点に立てるか（地形が歩ける かつ 障害物と重ならない）。
pub fn passable(
  spec : Spec,
  cols : Array[Collider],
  x : Double,
  z : Double,
) -> Bool {
  is_walkable(spec, x, z) && !blocked(cols, x, z)
}
