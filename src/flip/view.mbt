///|
using @element {
  div,
  span,
  h1,
  h2,
  p,
  a,
  button,
  text,
  fragment,
  events,
  type DomNode,
}

// スタイルの方針:
// - レイアウトや汎用的な装飾は tailwind ユーティリティ（class= に直接書く。
//   pages/styles.css の @source が .mbt をスキャンして抽出する）
// - 盤面セルなどゲーム固有のスタイルと動的な値（グリッド列数）は
//   @css（mizchi/luna/x/css）で生成し、main.mbt が <style id="luna-css"> に注入する
// - cell / blue / red / stubborn などの意味クラスはスタイルを持たないマーカーとして
//   残し、テストからの検証に使う
//
// レイアウトの方針:
// - ページ全体を h-dvh の縦 flex に収め、どのデバイスでもスクロールさせない
// - 盤面が flex-1 の中央、説明は「？」ボタンから開くモーダルに退避
// - 勝利/手詰まりメッセージは固定高さのスロットに出してレイアウトを揺らさない

///|
/// アプリ全体の状態。ゲーム本体（core）と UI だけの状態（モーダル開閉）を分けて持つ。
pub(all) struct AppState {
  game : @core.GameState
  rules_open : Bool
} derive(Eq, Debug)

///|
/// アプリへのメッセージ。ゲーム操作は core の Action をそのまま包む。
pub(all) enum Msg {
  Game(@core.Action)
  OpenRules
  CloseRules
} derive(Eq, Debug)

///|
/// 初期状態。
pub fn init_app() -> AppState {
  { game: @core.initial_state(0), rules_open: false }
}

///|
/// メッセージを適用して新しい状態を返す純関数。
pub fn update_app(state : AppState, msg : Msg) -> AppState {
  match msg {
    Game(action) => { ..state, game: @core.update(state.game, action) }
    OpenRules => { ..state, rules_open: true }
    CloseRules => { ..state, rules_open: false }
  }
}

///|
/// セルの共通スタイル。モバイルは 2.5rem、sm 以上で 3.25rem。
/// 高さの低い画面（横持ちスマホ等）ではさらに縮めて無スクロールを保つ。
fn cell_base() -> String {
  @css.combine([
    @css.styles([
      ("width", "2.5rem"),
      ("height", "2.5rem"),
      ("border-radius", "0.625rem"),
      ("display", "flex"),
      ("align-items", "center"),
      ("justify-content", "center"),
      ("font-size", "1rem"),
      ("color", "#fff"),
      ("user-select", "none"),
    ]),
    @css.at_sm("width", "3.25rem"),
    @css.at_sm("height", "3.25rem"),
    @css.at_sm("font-size", "1.125rem"),
    @css.media("max-height:520px", "width", "2rem"),
    @css.media("max-height:520px", "height", "2rem"),
    @css.media("max-height:520px", "font-size", "0.875rem"),
  ])
}

///|
/// 頑固者の見た目（太字 + 内側の白いリング）。
fn stubborn_style() -> String {
  @css.styles([
    ("font-weight", "700"),
    ("box-shadow", "inset 0 0 0 3px rgba(255,255,255,0.35)"),
  ])
}

///|
/// 意見ごとの背景色。頑固者は濃い色。
fn cell_face(color : @core.Color, stubborn : Bool) -> String {
  match (color, stubborn) {
    (Blue, false) => @css.css("background", "#3b82f6")
    (Red, false) => @css.css("background", "#ef4444")
    (Blue, true) => @css.combine([@css.css("background", "#1e40af"), stubborn_style()])
    (Red, true) => @css.combine([@css.css("background", "#991b1b"), stubborn_style()])
  }
}

///|
/// 説得できるマスの操作演出。tailwind の hover: は v4 ではホバーできる
/// デバイスにだけ効き、タッチ端末では active: の押下フィードバックが働く。
fn clickable_class() -> String {
  "cursor-pointer transition-transform duration-150 hover:scale-105 hover:shadow-lg active:scale-95"
}

///|
/// マスの表示文字。賛成=賛 / 反対=反。
fn cell_label(cell : @core.Cell) -> String {
  match cell.color {
    Blue => "賛"
    Red => "反"
  }
}

///|
/// マスの class。マーカークラス + @css の生成クラス。
fn cell_class(cell : @core.Cell, clickable : Bool) -> String {
  let color = match cell.color {
    Blue => "blue"
    Red => "red"
  }
  let stubborn = if cell.stubborn { " stubborn" } else { "" }
  let can_click = clickable && !(cell.stubborn)
  let click = if can_click { " clickable" } else { "" }
  let styles = @css.combine([cell_base(), cell_face(cell.color, cell.stubborn)])
  let interactive = if can_click { " " + clickable_class() } else { "" }
  "cell \{color}\{stubborn}\{click} \{styles}\{interactive}"
}

///|
/// 上部バー。戻るリンク・タイトル・説明モーダルを開く「？」ボタン。
fn topbar_view(dispatch : (Msg) -> Unit) -> DomNode {
  div(class="topbar flex items-center justify-between") <| [
    a(href="/", class="back w-8 text-left text-sm text-gray-500 hover:text-ink") <| [
      text("←"),
    ],
    h1(class="text-xl font-bold tracking-[0.3em] [text-indent:0.3em] sm:text-2xl") <| [
      text("セロン"),
    ],
    button(
      class="help h-8 w-8 cursor-pointer rounded-full border border-gray-300 bg-white text-sm text-gray-600",
      on=events().click(_ => dispatch(OpenRules)),
    ) <|
    [text("？")],
  ]
}

///|
/// 盤面。クリックで説得（Persuade）を発行する。列数はレベルごとに動的なので @css で生成。
fn board_view(game : @core.GameState, dispatch : (Msg) -> Unit) -> DomNode {
  let board = game.board
  let clickable = game.points_left > 0 && !(board.is_won())
  let cells : Array[DomNode] = []
  for y in 0..<board.height {
    for x in 0..<board.width {
      match board.get(x, y) {
        Some(cell) =>
          cells.push(
            div(
              class=cell_class(cell, clickable),
              on=events().click(_ => dispatch(Game(@core.Persuade(x, y)))),
            ) <| [text(cell_label(cell))],
          )
        None => ()
      }
    }
  }
  let columns = @css.css(
    "grid-template-columns",
    "repeat(\{board.width}, max-content)",
  )
  div(class="board grid w-fit justify-center gap-1 rounded-2xl bg-[#e7e3da] p-2 sm:gap-1.5 sm:p-3 \{columns}") <|
  cells
}

///|
/// レベル切り替えタブ。
fn tabs_view(game : @core.GameState, dispatch : (Msg) -> Unit) -> DomNode {
  let buttons : Array[DomNode] = []
  for i in 0..<@core.levels().length() {
    let base = "tab h-8 w-8 cursor-pointer rounded-full border text-sm sm:h-9 sm:w-9"
    let cls = if i == game.level_index {
      "\{base} active border-ink bg-ink text-white"
    } else {
      "\{base} border-gray-300 bg-white"
    }
    buttons.push(
      button(class=cls, on=events().click(_ => dispatch(Game(@core.Select(i))))) <| [
        text("\{i + 1}"),
      ],
    )
  }
  div(class="tabs mt-2 flex justify-center gap-2") <| buttons
}

///|
/// レベル名と説明。説明は高さを確保してレベル切替時のガタつきを防ぐ。
fn level_head_view(game : @core.GameState, level : @core.Level) -> DomNode {
  div(class="level-head") <| [
    h2(class="mt-1 text-sm font-semibold sm:text-base") <| [
      text("Lv.\{game.level_index + 1} \{level.name}"),
    ],
    p(class="intro mx-auto min-h-8 max-w-md text-xs text-gray-600 sm:min-h-9 sm:text-sm") <| [
      text(level.intro),
    ],
  ]
}

///|
/// 残り説得ポイントとステップ数。
fn status_view(game : @core.GameState) -> DomNode {
  let badge = "badge rounded-full border border-gray-200 bg-white px-3 py-1 text-xs sm:text-[13px]"
  div(class="status flex flex-wrap justify-center gap-2") <| [
    span(class=badge) <| [text("説得できる人数 \{game.points_left}")],
    span(class=badge) <| [text("経過ステップ \{game.steps}")],
  ]
}

///|
/// 操作ボタンの class。
fn button_class(primary : Bool) -> String {
  let base = "cursor-pointer rounded-[10px] border px-4 py-2 text-sm disabled:cursor-default disabled:opacity-40 sm:px-5 sm:py-2.5 sm:text-[15px]"
  if primary {
    "\{base} primary border-ink bg-ink text-white"
  } else {
    "\{base} border-gray-300 bg-white"
  }
}

///|
/// 操作ボタン列。
fn controls_view(game : @core.GameState, dispatch : (Msg) -> Unit) -> DomNode {
  div(class="controls flex justify-center gap-2.5") <| [
    button(
      class=button_class(true),
      disabled=game.board.is_won(),
      on=events().click(_ => dispatch(Game(@core.Advance))),
    ) <|
    [text("議論を進める")],
    button(class=button_class(false), on=events().click(_ => dispatch(
      Game(@core.Reset),
    ))) <|
    [text("やり直す")],
  ]
}

///|
/// 勝利・手詰まりのメッセージ。固定高さのスロットに出し、
/// 出現してもレイアウトが動かない（=スクロールが発生しない）ようにする。
fn message_view(game : @core.GameState, used : Int) -> DomNode {
  let slot = "message-slot flex h-10 items-center justify-center"
  if game.board.is_won() {
    div(class=slot) <| [
      span(class="message won rounded-full bg-blue-100 px-4 py-1.5 text-xs text-blue-800 sm:text-sm") <| [
        text("全会一致！ 説得\{used}人・\{game.steps}ステップで可決した。"),
      ],
    ]
  } else if game.is_stuck() {
    div(class=slot) <| [
      span(class="message stuck rounded-full bg-red-100 px-4 py-1.5 text-xs text-red-800 sm:text-sm") <| [
        text("議論が膠着…。「やり直す」で再挑戦しよう。"),
      ],
    ]
  } else {
    div(class=slot) <| []
  }
}

///|
/// あそびかたモーダル。背景クリックか「×」で閉じる。
fn rules_modal(dispatch : (Msg) -> Unit) -> DomNode {
  let para = "my-2 text-sm text-gray-600"
  div(
    class="modal-backdrop fixed inset-0 z-10 flex items-center justify-center bg-black/40 p-4",
    on=events().click(_ => dispatch(CloseRules)),
  ) <| [
    div(
      class="modal max-h-[80dvh] w-full max-w-md overflow-y-auto rounded-2xl bg-white p-5 text-left",
      on=events().click(e => e.stopPropagation()),
    ) <| [
      div(class="mb-1 flex items-center justify-between") <| [
        h2(class="text-base font-semibold") <| [text("あそびかた")],
        button(
          class="close h-8 w-8 cursor-pointer rounded-full border border-gray-300 text-sm text-gray-600",
          on=events().click(_ => dispatch(CloseRules)),
        ) <|
        [text("×")],
      ],
      p(class="text-xs text-gray-400") <| [
        text("世論をひっくり返す、多数決のパズル"),
      ],
      p(class=para) <| [
        text(
          "マスをクリックすると、その人ひとりを説得して意見を反転できる（持ち点を1消費）。",
        ),
      ],
      p(class=para) <| [
        text(
          "「議論を進める」を押すと、全員が同時に「自分と隣接マスの多数派」に意見を合わせる。" +
          "少数派に説得された人は同調圧力で元に戻されてしまうが、袋小路に追い込まれた反対派は雪崩のように寝返っていく。",
        ),
      ],
      p(class=para) <| [
        text(
          "濃い色のマスは頑固者。意見を絶対に変えないが、票としては数えられる。" +
          "頑固な反対派以外の全員を賛成（青）にすれば勝ちだ。",
        ),
      ],
      p(class=para) <| [
        text("どのレベルも、持ち点ちょうどの説得人数で解けることが保証されている。"),
      ],
    ],
  ]
}

///|
/// アプリ全体のビュー。h-dvh の縦 flex に収め、盤面が flex-1 の中央に座る。
pub fn app_view(state : AppState, dispatch : (Msg) -> Unit) -> DomNode {
  let game = state.game
  let level = @core.levels()[game.level_index]
  let used = level.budget - game.points_left
  div(class="app mx-auto flex h-full max-w-2xl flex-col px-3 py-2 text-center sm:px-4") <| [
    topbar_view(dispatch),
    tabs_view(game, dispatch),
    level_head_view(game, level),
    status_view(game),
    div(class="flex min-h-0 flex-1 items-center justify-center") <| [
      board_view(game, dispatch),
    ],
    controls_view(game, dispatch),
    message_view(game, used),
    if state.rules_open {
      rules_modal(dispatch)
    } else {
      fragment([])
    },
  ]
}
