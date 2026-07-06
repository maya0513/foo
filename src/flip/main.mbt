///|
/// 最新の dispatch を保持する橋渡し。popstate リスナーは起動時に1回だけ
/// 登録するが、dispatch は run が呼ばれるたびに作り直されるため、
/// リスナー側は常にこの箱を経由して「そのとき最新の」dispatch を呼ぶ。
priv struct DispatchBox {
  mut dispatch : (Msg) -> Unit
}

///|
let dispatch_box : DispatchBox = { dispatch: fn(_msg) { () } }

///|
/// エントリポイント。保存済みのクリア状況・URL（`?stage=N`）を読み込んで
/// #app にゲームをマウントし、ブラウザの戻る/進むボタン（popstate）を購読する。
fn main {
  match @dom.document().getElementById("app") {
    Some(el) => {
      let cleared = load_cleared(@core.levels().length())
      let stage = parse_stage(
        @location.location().search,
        @core.levels().length(),
      )
      let initial = match stage {
        Some(i) => {
          // 直リンク・リロード時の救済: Select エントリを合成してから
          // Play(i) を初期状態にする。これが無いと「戻る」で1段階も
          // 戻れずサイト外に出てしまう。
          @history.history().replaceState(@jscore.null(), "", url="/flip/")
          @history.history().pushState(@jscore.null(), "", url=stage_query(i))
          { ..init_app(cleared), screen: Play(@core.initial_state(i)) }
        }
        None => init_app(cleared)
      }
      @dom.window().add_popstate_listener(fn(_event) {
        let stage = parse_stage(
          @location.location().search,
          @core.levels().length(),
        )
        (dispatch_box.dispatch)(SyncRoute(stage))
      })
      run(el, initial)
    }
    None => println("Error: #app element not found")
  }
}

///|
/// Elm 風のループ。状態を描画し、メッセージが来たら update した新しい状態で描き直す。
/// 状態はこの関数の引数としてだけ存在し、可変のグローバルを持たない
/// （dispatch_box は popstate から最新の dispatch を呼ぶための橋渡しで、
/// アプリの状態そのものは持たない）。
/// クリア状況が変わったときだけ localStorage へ、画面遷移が起きたときだけ
/// history へ書き込む（副作用はここに閉じる）。
fn run(el : @dom.Element, state : AppState) -> Unit {
  let dispatch = fn(msg : Msg) -> Unit {
    let next = update_app(state, msg)
    if next.cleared != state.cleared {
      save_cleared(next.cleared)
    }
    match msg {
      SyncRoute(_) => ()
      _ => sync_url(state.screen, next.screen)
    }
    run(el, next)
  }
  dispatch_box.dispatch = dispatch
  @element.render_to(el, app_view(state, dispatch))
  inject_luna_css()
}

///|
/// ビュー構築時に @css が登録したアトミック CSS を <style id="luna-css"> へ反映する。
/// 描画のたびに呼ぶことで、後から現れるスタイルも漏れなく載る（登録はハッシュで冪等）。
fn inject_luna_css() -> Unit {
  match @dom.document().getElementById("luna-css") {
    Some(style_el) =>
      style_el.as_node().setTextContent(@css.generate_full_css())
    None => ()
  }
}
