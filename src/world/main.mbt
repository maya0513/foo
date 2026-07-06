///| エントリポイント。ローディング表示 → three 動的 import → シーン構築 →
/// 入力購読 → レンダーループ、という流れを組み立てる。
/// 純ロジックは core、three 操作は three/、可変の橋渡しは bridge。ここは配線だけ。

///|
fn main {
  @js.run_async(() => start())
}

///|
async fn start() -> Unit noraise {
  match @dom.document().getElementById("app") {
    None => println("Error: #app element not found")
    Some(app) => {
      let show_stick = is_coarse_pointer()
      build_hud(app, show_stick)

      // three を動的 import（この間ローディング画面が出ている）
      let m = @three.load() catch {
        err => {
          println("three の読み込みに失敗しました: \{err}")
          return
        }
      }
      let spec = @core.default_spec()
      let w = @dom.window().innerWidth().to_double()
      let h = @dom.window().innerHeight().to_double()
      let game0 = @core.init_game(spec)
      let stage = build_stage(m, spec, game0, w, h)
      let ratio = @dom.window().devicePixelRatio()
      stage.renderer.set_pixel_ratio(if ratio > 2.0 { 2.0 } else { ratio })
      stage.renderer.set_size(w, h)
      prepend_canvas(app.as_any(), stage.renderer.dom_element())
      subscribe_keyboard()
      if show_stick {
        subscribe_stick()
      }
      subscribe_resize(stage)
      set_stage_hook(stage.scene.as_any(), stage.camera.as_object3d().as_any())
      let lp : Loop = { game: game0, last_ms: now_ms(), moved: false }
      hide_loading()
      stage.renderer.set_animation_loop(fn() { frame(stage, spec, lp) })
    }
  }
}

///|
/// 1 フレーム: dt を測り、入力から step_game し、three へ反映して描画する。
fn frame(stage : Stage, spec : @core.Spec, lp : Loop) -> Unit {
  let t = now_ms()
  let raw = (t - lp.last_ms) / 1000.0
  lp.last_ms = t
  // タブ復帰などの巨大 dt を抑える
  let dt = if raw > 0.05 { 0.05 } else if raw < 0.0 { 0.0 } else { raw }
  let (strafe, forward) = current_axes()
  lp.game = @core.step_game(spec, lp.game, strafe, forward, dt)
  apply_frame(stage, lp.game)
  stage.renderer.render(stage.scene, stage.camera)
  let p = lp.game.player
  set_debug_hook(p.x, p.y, p.z, strafe, forward)
  if !lp.moved && (strafe.abs() > 0.05 || forward.abs() > 0.05) {
    lp.moved = true
    fade_hints()
  }
}

///|
fn subscribe_resize(stage : Stage) -> Unit {
  @dom.window()
  .as_event_target()
  .addEventListener("resize", fn(_e) {
    let w = @dom.window().innerWidth().to_double()
    let h = @dom.window().innerHeight().to_double()
    resize_stage(stage, w, h)
  })
}
