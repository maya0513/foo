///|
/// サイト名（ロジック層 — 状態を持たない純粋関数）。
pub fn site_title() -> String {
  "foo"
}

///|
/// 公開しているコンテンツの一覧（名前, パス, 説明）。
pub fn games() -> Array[(String, String, String)] {
  [
    ("フリップ", "/flip/", "白と黒の反転パズル"),
    (
      "そよかぜの丘", "/world/", "低ポリの島を歩くオープンワールド",
    ),
  ]
}

///|
using @element {
  a,
  div,
  h1,
  h2,
  header_,
  li,
  main_,
  render_to,
  span,
  text,
  ul,
  type DomNode,
}

///|
/// コンテンツ一覧の項目。
fn game_items() -> Array[DomNode] {
  let items : Array[DomNode] = []
  for game in games() {
    let (name, path, desc) = game
    items.push(
      li() <| [
        a(
          href=path,
          class="game-link font-semibold text-blue-700 hover:underline",
        ) <| [
          text(name),
        ],
        span(class="desc text-sm text-gray-600") <| [
          text(" - " + desc),
        ],
      ],
    )
  }
  items
}

///|
/// トップページ（描画層）。ヘッダーにサイト名、本文にコンテンツ一覧という
/// オーソドックスなサイト配置。スタイルは tailwind ユーティリティで記述する。
pub fn view() -> DomNode {
  div() <| [
    header_(class="border-b border-gray-200 bg-white") <| [
      div(class="mx-auto max-w-4xl px-4 py-4") <| [
        h1(class="text-xl font-bold") <| [
          text(site_title()),
        ],
      ],
    ],
    main_(class="mx-auto max-w-4xl px-4 py-8") <| [
      h2(class="mt-8 mb-3 text-lg font-semibold") <| [
        text("コンテンツ"),
      ],
      ul(class="games list-disc space-y-2 pl-5") <| game_items(),
    ],
  ]
}
