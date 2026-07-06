///| 可変状態の箱。core は不変値で世界を表すが、ブラウザのイベント（キー・
/// ポインタ）と毎フレームのループは「その時点の最新状態」を共有する必要がある。
/// その橋渡しをここに閉じ込める。純ロジック（core）はこの箱を一切知らない。

///|
/// 押下中の方向キーと仮想スティックの入力状態。
priv struct InputState {
  mut up : Bool
  mut down : Bool
  mut left : Bool
  mut right : Bool
  mut stick_x : Double // 右が +
  mut stick_z : Double // 前（画面奥）が +
  mut stick_active : Bool
}

///|
let input : InputState = {
  up: false,
  down: false,
  left: false,
  right: false,
  stick_x: 0.0,
  stick_z: 0.0,
  stick_active: false,
}

///|
/// ループが持ち回るゲーム状態と時刻。
priv struct Loop {
  mut game : @core.GameState
  mut last_ms : Double
  mut moved : Bool
}

///|
/// 現在の入力からカメラ相対の (strafe, forward) を合成する。
/// スティックが有効ならスティック優先、そうでなければキー。
fn current_axes() -> (Double, Double) {
  if input.stick_active {
    @core.stick_axes(input.stick_x, input.stick_z, 0.16)
  } else {
    @core.keys_to_axes(input.up, input.down, input.left, input.right)
  }
}

///|
/// performance.now()（ミリ秒）。
extern "js" fn now_ms() -> Double =
  #| () => performance.now()

///|
/// canvas を #app の背面に差し込む（HUD オーバーレイより下）。
extern "js" fn prepend_canvas(
  container : @jscore.Any,
  canvas : @jscore.Any,
) -> Unit =
  #| (container, canvas) => { container.insertBefore(canvas, container.firstChild); }

///|
/// dev / E2E 用フック。毎フレーム、プレイヤー座標を globalThis.__world に出す。
extern "js" fn set_debug_hook(
  x : Double,
  y : Double,
  z : Double,
  strafe : Double,
  forward : Double,
) -> Unit =
  #| (x, y, z, strafe, forward) => { globalThis.__world = { x, y, z, strafe, forward }; }

///|
/// dev / E2E 用フック。シーングラフを globalThis.__stage に出して外から検分できるようにする。
extern "js" fn set_stage_hook(
  scene : @jscore.Any,
  camera : @jscore.Any,
) -> Unit =
  #| (scene, camera) => { globalThis.__stage = { scene, camera }; }

///|
/// 要素の style プロパティを直接いじる（スティックのノブ移動など、
/// luna の再描画を通さず軽量に更新するため）。
extern "js" fn set_style(
  el : @jscore.Any,
  prop : String,
  value : String,
) -> Unit =
  #| (el, prop, value) => { el.style[prop] = value; }

///|
/// 要素の getBoundingClientRect（DOMRect）。FFI 境界でタプルは表現が合わないので
/// Any で受けて _get で読む。
extern "js" fn bounding_rect_raw(el : @jscore.Any) -> @jscore.Any =
  #| (el) => el.getBoundingClientRect()

///|
fn bounding_rect(el : @jscore.Any) -> (Double, Double, Double, Double) {
  let r = bounding_rect_raw(el)
  (
    r._get("left").cast(),
    r._get("top").cast(),
    r._get("width").cast(),
    r._get("height").cast(),
  )
}

///|
/// (pointer: coarse) にマッチするか（タッチ主体の端末か）。
extern "js" fn is_coarse_pointer() -> Bool =
  #| () => window.matchMedia('(pointer: coarse)').matches

///|
/// 要素の最初の子要素（スティックのノブ）。
extern "js" fn first_element_child(el : @jscore.Any) -> @jscore.Any =
  #| (el) => el.firstElementChild

///|
/// document.querySelector。マウント後の実要素を掴むため。
extern "js" fn query_one(sel : String) -> @jscore.Any =
  #| (sel) => document.querySelector(sel)

///|
/// 実要素（Any）へリスナを付ける汎用ヘルパ。
extern "js" fn add_listener(
  target : @jscore.Any,
  ev : String,
  f : (@jscore.Any) -> Unit,
) -> Unit =
  #| (target, ev, f) => { target.addEventListener(ev, f, { passive: false }); }
