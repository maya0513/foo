///|
/// 表示するメッセージ（ロジック層 — 状態を持たない純粋関数）。
pub fn message() -> String {
  "hello world"
}

///|
using @element { h1, text, render_to, type DomNode }

///|
/// hello world を表示する UI（描画層）。
pub fn view() -> DomNode {
  h1() <| [text(message())]
}
