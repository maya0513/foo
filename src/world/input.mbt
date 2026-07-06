///| 入力の購読。DOM イベントを InputState（bridge）へ流し込むだけで、
/// 移動の意味づけ（正規化・カメラ相対化）は core が担う。

///|
/// 仮想スティックの操作に必要な DOM 参照と幾何。
priv struct StickCtl {
  mut knob : @jscore.Any
  mut cx : Double
  mut cy : Double
  mut radius : Double
  mut dragging : Bool
}

///|
let stick : StickCtl = {
  knob: @jscore.undefined(),
  cx: 0.0,
  cy: 0.0,
  radius: 60.0,
  dragging: false,
}

///|
/// イベントから clientX/clientY を取り出す。
fn pointer_xy(e : @jscore.Any) -> (Double, Double) {
  (e._get("clientX").cast(), e._get("clientY").cast())
}

///|
/// キー文字列を InputState のフラグへ反映。既知キーなら true を返す。
fn set_key(key : String, pressed : Bool) -> Bool {
  match key {
    "w" | "W" | "ArrowUp" => input.up = pressed
    "s" | "S" | "ArrowDown" => input.down = pressed
    "a" | "A" | "ArrowLeft" => input.left = pressed
    "d" | "D" | "ArrowRight" => input.right = pressed
    _ => return false
  }
  true
}

///|
/// キーボード購読（window）。矢印キーの既定スクロールは抑止。
fn subscribe_keyboard() -> Unit {
  let target = @dom.window().as_event_target()
  target.addEventListener("keydown", fn(e) {
    if set_key(e._get("key").to_string(), true) {
      e._call("preventDefault", []) |> ignore
    }
  })
  target.addEventListener("keyup", fn(e) {
    set_key(e._get("key").to_string(), false) |> ignore
  })
  // フォーカスを失ったら全キー解除（押しっぱなし暴走を防ぐ）
  target.addEventListener("blur", fn(_e) {
    input.up = false
    input.down = false
    input.left = false
    input.right = false
  })
}

///|
/// スティックのノブ位置と InputState を、ポインタ座標から更新する。
fn update_stick(px : Double, py : Double) -> Unit {
  let dx = px - stick.cx
  let dy = py - stick.cy
  let r = stick.radius
  // ノブ表示は半径内にクランプ
  let len = (dx * dx + dy * dy).sqrt()
  let (kx, ky) = if len > r { (dx / len * r, dy / len * r) } else { (dx, dy) }
  set_style(
    stick.knob,
    "transform",
    "translate(" + kx.to_string() + "px," + ky.to_string() + "px)",
  )
  // 入力値は [-1,1]。画面の下方向(+y)は「後退」なので z は符号反転。
  input.stick_x = (dx / r).clamp(min=-1.0, max=1.0)
  input.stick_z = (-dy / r).clamp(min=-1.0, max=1.0)
  input.stick_active = true
}

///|
/// ノブを中央へ戻し、入力を解除。
fn release_stick() -> Unit {
  stick.dragging = false
  input.stick_active = false
  input.stick_x = 0.0
  input.stick_z = 0.0
  set_style(stick.knob, "transform", "translate(0px,0px)")
}

///|
/// スティック本体の pointerdown（luna の on= 経由）で掴む。
/// イベントの currentTarget から base 要素・ノブ・中心・半径を得る。
fn begin_stick(e : @jscore.Any) -> Unit {
  e._call("preventDefault", []) |> ignore
  let base = e._get("currentTarget")
  stick.knob = first_element_child(base)
  let (l, t, w, h) = bounding_rect(base)
  stick.cx = l + w / 2.0
  stick.cy = t + h / 2.0
  stick.radius = w / 2.0
  stick.dragging = true
  let (px, py) = pointer_xy(e)
  update_stick(px, py)
}

///|
/// 視点ドラッグの追跡状態。スティックとは別ポインタで独立に動く
/// （スティックのポインタはスティック要素が受けるため canvas へは届かない）。
priv struct DragCtl {
  mut active : Bool
  mut pointer_id : Double
  mut last_x : Double
  mut last_y : Double
}

///|
let drag : DragCtl = {
  active: false,
  pointer_id: -1.0,
  last_x: 0.0,
  last_y: 0.0,
}

///|
/// 視点操作の購読。canvas 上のドラッグ（マウス/スワイプ）で yaw/pitch、
/// ホイールでズーム。移動キーとは完全に独立。
fn subscribe_camera(canvas : @jscore.Any) -> Unit {
  add_listener(canvas, "pointerdown", fn(e) {
    let button : Double = e._get("button").cast()
    if button == 0.0 && !drag.active {
      drag.active = true
      drag.pointer_id = e._get("pointerId").cast()
      let (px, py) = pointer_xy(e)
      drag.last_x = px
      drag.last_y = py
    }
  })
  let win = @dom.window().as_event_target()
  win.addEventListener("pointermove", fn(e) {
    if drag.active {
      let id : Double = e._get("pointerId").cast()
      if id == drag.pointer_id {
        let (px, py) = pointer_xy(e)
        // ドラッグ右 → 視点も右へ（マウスルック規約）
        input.cam_dyaw = input.cam_dyaw + (px - drag.last_x) * 0.006
        input.cam_dpitch = input.cam_dpitch + (py - drag.last_y) * 0.004
        drag.last_x = px
        drag.last_y = py
      }
    }
  })
  let end_drag = fn(e : @jscore.Any) {
    if drag.active {
      let id : Double = e._get("pointerId").cast()
      if id == drag.pointer_id {
        drag.active = false
      }
    }
  }
  win.addEventListener("pointerup", end_drag)
  win.addEventListener("pointercancel", end_drag)
  // ホイールでズーム（1 ノッチ ≈ 1m）。ページスクロールは抑止
  add_listener(canvas, "wheel", fn(e) {
    e._call("preventDefault", []) |> ignore
    let dy : Double = e._get("deltaY").cast()
    input.cam_dzoom = input.cam_dzoom + dy * 0.01
  })
}

///|
/// スティックのドラッグ購読。pointerdown はマウント後の実要素へ直接結び
/// （luna の on= / ref_ はここで返す仮想ノードと実ノードがずれるため使わない）、
/// 以降の追従は window で拾う（指が本体外へ出ても切れない）。
fn subscribe_stick() -> Unit {
  let base = query_one("#world-stick")
  add_listener(base, "pointerdown", fn(e) { begin_stick(e) })
  let win = @dom.window().as_event_target()
  win.addEventListener("pointermove", fn(e) {
    if stick.dragging {
      let (px, py) = pointer_xy(e)
      update_stick(px, py)
    }
  })
  win.addEventListener("pointerup", fn(_e) { release_stick() })
  win.addEventListener("pointercancel", fn(_e) { release_stick() })
}
