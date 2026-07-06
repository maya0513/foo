///|
/// ワールド全体の仕様。地形生成・散布・物理すべてがこの一枚から決まる。
/// seed を固定しているので、同じ spec からは常に同じ世界が再生成される。
pub(all) struct Spec {
  seed : UInt
  half_size : Double // ワールド半径（-half..half の正方領域）
  segs : Int // 地形グリッドの分割数（頂点は segs+1 の二乗）
  height_scale : Double // 起伏の最大高さ
  base_freq : Double // ノイズのサンプリング周波数
  octaves : Int
  lacunarity : Double
  gain : Double
  shore : Double // 島の縁を水没させる沈み込み量
  water_level : Double // 水面の y
}

///|
/// オープンワールドの既定仕様。牧歌的で歩き回れる島になるよう調整済み。
pub fn default_spec() -> Spec {
  {
    seed: 20260706U,
    half_size: 92.0,
    segs: 128,
    height_scale: 32.0,
    base_freq: 0.017,
    octaves: 5,
    lacunarity: 2.05,
    gain: 0.5,
    shore: 0.12,
    water_level: 0.0,
  }
}

///|
/// 移動速度 [m/s]。
pub let move_speed : Double = 11.0

///|
/// ゲームの可変状態。core は「世界の真実」を保持し、表示層がこれを読む。
pub(all) struct GameState {
  player : Player
  camera : Camera
  time : Double
} derive(Eq)

///|
/// 初期状態。スポーン地点にプレイヤーを置き、カメラをその後方に構える。
pub fn init_game(spec : Spec) -> GameState {
  let player = player_spawn(spec)
  let camera = camera_init(spec, player)
  { player, camera, time: 0.0 }
}

///|
/// 1 フレーム進める。移動入力はカメラ相対の (strafe, forward)（各 -1..1）、
/// 視点入力は (dyaw, dpitch, dzoom)。移動と視点は独立：キーは移動だけ、
/// ドラッグ/スワイプ/ホイールは視点だけを動かす。
pub fn step_game(
  spec : Spec,
  state : GameState,
  cols : Array[Collider],
  strafe : Double,
  forward : Double,
  dyaw : Double,
  dpitch : Double,
  dzoom : Double,
  dt : Double,
) -> GameState {
  let yaw = camera_yaw(state.camera)
  let (dx, dz) = move_direction(strafe, forward, yaw)
  let player = step_player(spec, state.player, cols, dx, dz, move_speed, dt)
  let camera = step_camera(spec, state.camera, player, dyaw, dpitch, dzoom, dt)
  { player, camera, time: state.time + dt }
}
