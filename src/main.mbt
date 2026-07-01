///|
/// エントリポイント。#app に view() をマウントする。
fn main {
  match @dom.document().getElementById("app") {
    Some(el) => render_to(el, view())
    None => println("Error: #app element not found")
  }
}
