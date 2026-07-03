///|
/// エントリポイント。#app にゲームをマウントする。
fn main {
  match @dom.document().getElementById("app") {
    Some(el) => run(el, init_app())
    None => println("Error: #app element not found")
  }
}

///|
/// Elm 風のループ。状態を描画し、メッセージが来たら update した新しい状態で描き直す。
/// 状態はこの関数の引数としてだけ存在し、可変のグローバルを持たない。
fn run(el : @dom.Element, state : AppState) -> Unit {
  @element.render_to(el, app_view(state, msg => run(el, update_app(state, msg))))
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
