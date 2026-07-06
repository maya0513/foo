///| HUD は luna で一度だけ構築する静的オーバーレイ。タイトル・操作ヒント・
/// 仮想スティック・ローディング画面を持つ。毎フレーム再描画はしない
/// （ノブは style.transform を直接更新、ヒントは opacity を直接操作）。

///|
/// HUD 内で後から触る要素の参照。
priv struct HudRefs {
  mut hints : @jscore.Any
  mut loading : @jscore.Any
}

///|
let hud_refs : HudRefs = {
  hints: @jscore.undefined(),
  loading: @jscore.undefined(),
}

///|
/// オーバーレイ DOM を組んで #app に載せる。show_stick=true でスティック表示。
fn build_hud(app : @dom.Element, show_stick : Bool) -> Unit {
  let overlay = @dom.document().createElement("div")
  overlay.setAttribute("class", "absolute inset-0 pointer-events-none")
  overlay.setAttribute("style", "position:absolute;inset:0;")
  @element.render_to(overlay, hud_view(show_stick))
  app.appendChild(overlay.as_node()) |> ignore
  inject_luna_css()
}

///|
fn hud_view(show_stick : Bool) -> @element.DomNode {
  let children : Array[@element.DomNode] = [title_card(), hints_card()]
  if show_stick {
    children.push(joystick())
  }
  children.push(loading_screen())
  @element.div(class="absolute inset-0", children)
}

///|
fn title_card() -> @element.DomNode {
  @element.div(
    class="absolute left-4 top-4 rounded-2xl bg-white/55 px-4 py-3 shadow-lg backdrop-blur",
    [
      @element.div(class="text-lg font-bold text-slate-800", [
        @element.text("そよかぜの丘"),
      ]),
      @element.div(class="text-xs font-medium tracking-wide text-slate-600", [
        @element.text("Breezy Hills"),
      ]),
    ],
  )
}

///|
fn hints_card() -> @element.DomNode {
  @element.div(
    class="absolute right-4 top-4 rounded-xl bg-white/45 px-3 py-2 text-xs text-slate-700 shadow backdrop-blur transition-opacity duration-1000",
    ref_=fn(el) { hud_refs.hints = el.as_any() },
    [@element.text("WASD / 矢印キーで散策")],
  )
}

///|
/// 仮想スティック。base に pointer-events-auto + touch-none、内側にノブ。
/// pointerdown は luna の on= で確実に実要素へ結び、以降の追従は window で拾う。
fn joystick() -> @element.DomNode {
  @element.div(
    id="world-stick",
    class="pointer-events-auto absolute bottom-8 left-8 flex h-32 w-32 touch-none items-center justify-center rounded-full border border-white/50 bg-white/20 shadow-lg backdrop-blur",
    [@element.div(class="h-16 w-16 rounded-full bg-white/70 shadow-md", [])],
  )
}

///|
/// ローディング画面（three import 中に表示）。
fn loading_screen() -> @element.DomNode {
  @element.div(
    class="absolute inset-0 flex flex-col items-center justify-center gap-3 transition-opacity duration-700",
    style="background:linear-gradient(180deg,#bfe6ff 0%,#e9f6e0 100%)",
    ref_=fn(el) { hud_refs.loading = el.as_any() },
    [
      @element.div(class="text-2xl font-bold text-slate-700", [
        @element.text("そよかぜの丘"),
      ]),
      @element.div(class="text-sm text-slate-500", [
        @element.text("世界を生成しています…"),
      ]),
    ],
  )
}

///|
/// ローディングを消す（フェードアウト後 display:none）。
fn hide_loading() -> Unit {
  set_style(hud_refs.loading, "opacity", "0")
  @js.setTimeout(fn() { set_style(hud_refs.loading, "display", "none") }, 800)
  |> ignore
}

///|
/// 初回移動後に操作ヒントをフェードさせる。
fn fade_hints() -> Unit {
  set_style(hud_refs.hints, "opacity", "0")
}

///|
/// luna が登録したアトミック CSS を <style id="luna-css"> へ反映。
fn inject_luna_css() -> Unit {
  match @dom.document().getElementById("luna-css") {
    Some(style_el) =>
      style_el.as_node().setTextContent(@css.generate_full_css())
    None => ()
  }
}
