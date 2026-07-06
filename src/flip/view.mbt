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
// - cell / white / black / fixed などの意味クラスはスタイルを持たないマーカーとして
//   残し、テストからの検証に使う
//
// レイアウトの方針:
// - ページ全体を h-dvh の縦 flex に収め、どのデバイスでもスクロールさせない
//   （ステージ選択もプレイ画面も同様）
// - 盤面が flex-1 の中央、あそびかた・答えはモーダルに退避
// - クリア/手詰まりメッセージは固定高さのスロットに出してレイアウトを揺らさない

///|
/// 画面。ステージ選択か、ゲームのプレイ中か。
pub(all) enum Screen {
  Select
  Play(@core.GameState)
} derive(Eq, Debug)

///|
/// 開いているモーダル。AnswerConfirm は答えを見る前の確認。
pub(all) enum Modal {
  NoModal
  Rules
  AnswerConfirm
  Answer
} derive(Eq, Debug)

///|
/// アプリ全体の状態。ゲーム本体（core）と UI だけの状態（画面・モーダル・
/// クリア済みステージ）を分けて持つ。クリア状況の読み書きは main.mbt が行い、
/// この層は純粋に保つ。
pub(all) struct AppState {
  screen : Screen
  modal : Modal
  cleared : Array[Bool]
} derive(Eq, Debug)

///|
/// アプリへのメッセージ。ゲーム操作は core の Action をそのまま包む。
/// SyncRoute はブラウザの戻る/進むボタン（popstate）由来の画面同期専用で、
/// history には一切書き込まない（main.mbt の run がそこで分岐する）。
pub(all) enum Msg {
  Enter(Int)
  Back
  Next
  Game(@core.Action)
  OpenRules
  OpenAnswer
  ShowAnswer
  CloseModal
  SyncRoute(Int?)
} derive(Eq, Debug)

///|
/// 初期状態。ステージ選択画面から始まる。cleared は保存済みのクリア状況。
pub fn init_app(cleared : Array[Bool]) -> AppState {
  { screen: Select, modal: NoModal, cleared }
}

///|
/// クリア済みマークを立てた新しい配列を返す。
fn mark_cleared(cleared : Array[Bool], index : Int) -> Array[Bool] {
  let next = cleared.copy()
  if index >= 0 && index < next.length() {
    next[index] = true
  }
  next
}

///|
/// メッセージを適用して新しい状態を返す純関数。
pub fn update_app(state : AppState, msg : Msg) -> AppState {
  match msg {
    Enter(i) =>
      if i >= 0 && i < @core.levels().length() {
        { ..state, screen: Play(@core.initial_state(i)), modal: NoModal }
      } else {
        state
      }
    Back => { ..state, screen: Select, modal: NoModal }
    Next =>
      match state.screen {
        Play(game) => {
          let next = game.level_index + 1
          if next < @core.levels().length() {
            { ..state, screen: Play(@core.initial_state(next)), modal: NoModal }
          } else {
            { ..state, screen: Select, modal: NoModal }
          }
        }
        Select => state
      }
    Game(action) =>
      match state.screen {
        Play(game) => {
          let next = @core.update(game, action)
          let cleared = if next.board.is_won() {
            mark_cleared(state.cleared, next.level_index)
          } else {
            state.cleared
          }
          { ..state, screen: Play(next), cleared }
        }
        Select => state
      }
    OpenRules => { ..state, modal: Rules }
    OpenAnswer => { ..state, modal: AnswerConfirm }
    ShowAnswer => { ..state, modal: Answer }
    CloseModal => { ..state, modal: NoModal }
    SyncRoute(Some(i)) =>
      { ..state, screen: Play(@core.initial_state(i)), modal: NoModal }
    SyncRoute(None) => { ..state, screen: Select, modal: NoModal }
  }
}

///|
/// 「幅方向の制約」と「高さ方向の制約」のうち小さいほうを採用し、
/// min_size 〜 max_size にクランプする正方形セルのサイズ式を作る。
/// これにより、盤面・グリッドが小さいステージでは画面を活かして大きく、
/// 大きいステージでは画面からはみ出さないよう自動的に縮む
/// （無スクロールを保ったまま、余白の偏りを解消する）。
///
/// - available_w: 利用可能幅を表す CSS 式（ブレークポイントごとに変える）
/// - header_h: ヘッダー・フッターなど盤面/グリッド以外が占める高さの概算（rem）
fn fit_size(
  cols : Int,
  rows : Int,
  available_w : String,
  header_h : String,
  gap : String,
  min_size : String,
  max_size : String,
) -> String {
  let w = "calc((\{available_w} - \{cols - 1} * \{gap}rem) / \{cols})"
  let h = "calc((100dvh - \{header_h}rem - \{rows - 1} * \{gap}rem) / \{rows})"
  "clamp(\{min_size}rem, min(\{max_size}rem, \{w}, \{h}), \{max_size}rem)"
}

///|
/// セルの共通スタイル。
/// 幅は「app の左右パディング + 盤面自体の左右パディング」を、高さは
/// 「トップバー・見出し・ステータス・操作ボタン・メッセージ欄など
/// 盤面以外が占める高さの概算（実測ベース、約14.5rem）+ 盤面自体の上下パディング」
/// を差し引いて算出する（fit_size の header_h は「グリッド以外＋グリッド自身の
/// パディング」の合計を渡す設計。gap 分は fit_size 側で別途差し引かれる）。
fn cell_base(cols : Int, rows : Int) -> String {
  // モバイル: app px-3(0.75rem)*2 + 盤面 p-2(0.5rem)*2 = 2.5rem。
  let mobile_fit = fit_size(
    cols, rows, "calc(100vw - 2.5rem)", "16", "0.25", "1.75", "4.5",
  )
  // sm 以上: app は max-w-3xl(48rem) で頭打ちになるので min(100vw, 48rem) を使う。
  // app px-4(1rem)*2 + 盤面 sm:p-3(0.75rem)*2 = 3.5rem。
  // max_size は広い画面でセルが間延びして見えないよう、モバイルの見た目に近い
  // 上限で頭打ちにする（PC で不自然に大きくならないようにする）。
  let sm_fit = fit_size(
    cols, rows, "calc(min(100vw, 48rem) - 3.5rem)", "16.5", "0.375", "1.5", "5",
  )
  @css.combine([
    @css.styles([
      ("width", mobile_fit),
      ("height", mobile_fit),
      ("border-radius", "0.625rem"),
      ("display", "flex"),
      ("align-items", "center"),
      ("justify-content", "center"),
      ("font-size", "1rem"),
      ("user-select", "none"),
    ]),
    @css.at_sm("width", sm_fit),
    @css.at_sm("height", sm_fit),
    @css.at_sm("font-size", "1.125rem"),
  ])
}

///|
/// 色ごとの見た目。固定マスは二重枠で示す。
/// 台座色（#d9d4c8、board_view/answer_modal）に対してどちらの色もはっきり
/// 浮くよう、全マス共通の外側ドロップシャドウ + 白マスは太めの内枠で縁取る。
fn cell_face(color : @core.Color, fixed : Bool) -> String {
  let lift = "0 1px 2px rgba(31,41,55,0.2)"
  match (color, fixed) {
    (White, false) =>
      @css.styles([
        ("background", "#ffffff"),
        ("box-shadow", "\{lift}, inset 0 0 0 2px #9aa1ab"),
      ])
    (Black, false) =>
      @css.styles([("background", "#1f2937"), ("box-shadow", lift)])
    (White, true) =>
      @css.styles([
        ("background", "#ffffff"),
        (
          "box-shadow",
          "\{lift}, inset 0 0 0 1px #6b7280, inset 0 0 0 4px #ffffff, inset 0 0 0 6px #6b7280",
        ),
      ])
    (Black, true) =>
      @css.styles([
        ("background", "#1f2937"),
        (
          "box-shadow",
          "\{lift}, inset 0 0 0 2px #1f2937, inset 0 0 0 4px rgba(255,255,255,0.75)",
        ),
      ])
  }
}

///|
/// 反転できるマスの操作演出。tailwind の hover: は v4 ではホバーできる
/// デバイスにだけ効き、タッチ端末では active: の押下フィードバックが働く。
fn clickable_class() -> String {
  // shadow 系は @css（luna-css、後読み）の box-shadow に負けるので使わない
  "cursor-pointer transition-transform duration-150 hover:scale-105 active:scale-95"
}

///|
/// マスの class。マーカークラス + @css の生成クラス。
fn cell_class(
  cell : @core.Cell,
  clickable : Bool,
  cols : Int,
  rows : Int,
) -> String {
  let color = match cell.color {
    White => "white"
    Black => "black"
  }
  let fixed = if cell.fixed { " fixed-cell" } else { "" }
  let can_click = clickable && !cell.fixed
  let click = if can_click { " clickable" } else { "" }
  let styles = @css.combine([
    cell_base(cols, rows),
    cell_face(cell.color, cell.fixed),
  ])
  let interactive = if can_click { " " + clickable_class() } else { "" }
  "cell \{color}\{fixed}\{click} \{styles}\{interactive}"
}

///|
/// 丸い小さなアイコンボタン（？・×）の class。
fn icon_button_class() -> String {
  "h-8 w-8 cursor-pointer rounded-full border border-gray-300 bg-white text-sm text-gray-600"
}

///|
/// 上部バー。左スロット・中央タイトル・右スロット（ヘルプ系ボタン）。
/// 左右の幅が違ってもタイトルが中央からずれないよう 1fr auto 1fr のグリッドにする。
fn topbar_view(
  left : DomNode,
  extra : Array[DomNode],
  dispatch : (Msg) -> Unit,
) -> DomNode {
  div(
    class="topbar mx-auto grid w-full max-w-xl grid-cols-[1fr_auto_1fr] items-center",
  ) <| [
    div(class="flex justify-start") <| [
      left,
    ],
    h1(
      class="text-xl font-bold tracking-[0.3em] [text-indent:0.3em] sm:text-2xl",
    ) <| [
      text("フリップ"),
    ],
    {
      let right = extra +
        [
          button(
            class="help \{icon_button_class()}",
            on=events().click(_ => dispatch(OpenRules)),
          ) <| [
            text("？"),
          ],
        ]
      div(class="flex items-center justify-end gap-2") <| right
    },
  ]
}

///|
/// ステージ選択のグリッドの列数・行数（30ステージ = 5列 x 6行 固定）。
let stage_cols : Int = 5

///|
let stage_rows : Int = 6

///|
/// ステージボタンのサイズ。盤面セルと同じ fit_size の考え方で、
/// 画面の残り幅・残り高さに応じて可変にする（stages コンテナに
/// パディングは無いので、利用可能幅は app の内側幅そのまま）。
fn stage_size() -> String {
  // モバイル: app px-3(0.75rem)*2 = 1.5rem（stages にパディングは無い）。
  let mobile_fit = fit_size(
    stage_cols, stage_rows, "calc(100vw - 1.5rem)", "7", "0.5", "1.75", "4",
  )
  // max_size はモバイルの見た目に近い上限で頭打ちにし、PC で間延びしないようにする。
  let sm_fit = fit_size(
    stage_cols, stage_rows, "calc(min(100vw, 48rem) - 2rem)", "7", "0.625", "2.25",
    "4.5",
  )
  @css.combine([
    @css.styles([("width", mobile_fit), ("height", mobile_fit)]),
    @css.at_sm("width", sm_fit),
    @css.at_sm("height", sm_fit),
  ])
}

///|
/// ステージ選択のマスひとつ。盤面のマスと同じ言語で表現する:
/// 未クリアは黒マス（まだ染まっていない）、クリア済みは白マス+✓バッジ。
/// クリアするほど選択画面自体が白く反転していき、ゲームの目的がひと目で伝わる。
/// 背景（paper）に対する視認性もこれで確保される（旧 gray-100 は paper と
/// ほぼ同色で、ボタンが背景に溶けて無効にも見えていた）。
fn stage_button(
  index : Int,
  cleared : Bool,
  dispatch : (Msg) -> Unit,
) -> DomNode {
  let base = "stage relative \{clickable_class()} rounded-xl text-sm sm:text-base \{stage_size()}"
  let cls = if cleared {
    "\{base} done border-2 border-ink bg-white text-ink shadow-sm"
  } else {
    "\{base} border border-ink bg-ink text-white/90 shadow-sm"
  }
  let badge = if cleared {
    span(
      class="done-badge absolute -right-1 -top-1 flex h-4 w-4 items-center justify-center rounded-full bg-ink text-[10px] leading-none text-white",
    ) <| [
      text("✓"),
    ]
  } else {
    fragment([])
  }
  button(class=cls, on=events().click(_ => dispatch(Enter(index)))) <| [
    text("\{index + 1}"),
    badge,
  ]
}

///|
/// ステージ選択画面。30ステージがならぶ。
fn select_view(state : AppState, dispatch : (Msg) -> Unit) -> DomNode {
  let buttons : Array[DomNode] = []
  let mut cleared_count = 0
  for i in 0..<@core.levels().length() {
    let done = state.cleared[i]
    if done {
      cleared_count += 1
    }
    buttons.push(stage_button(i, done, dispatch))
  }
  let back = a(href="/", class="back text-sm text-gray-400 hover:text-ink") <| [
    text("←"),
  ]
  div(class="select flex h-full flex-col") <| [
    topbar_view(back, [], dispatch),
    p(class="tagline mt-1 text-xs text-gray-500 sm:text-sm") <| [
      text("白と黒の反転パズル"),
    ],
    // justify-center: 縦の残り空間の中央にグリッドを置き、画面下部に
    // 空白が偏らないようにする（盤面を flex-1 中央に置くプレイ画面と揃える）
    div(class="flex min-h-0 flex-1 flex-col items-center justify-center gap-3") <| [
      // grid-cols-5 は stage_cols(5)、gap は stage_size() の gap 引数と一致させること。
      div(class="stages grid grid-cols-5 gap-2 sm:gap-2.5") <| buttons,
      p(class="progress text-sm font-semibold text-ink/80 sm:text-base") <| [
        text("クリア \{cleared_count} / \{@core.levels().length()}"),
      ],
    ],
  ]
}

///|
/// 盤面。クリックで反転（Flip）を発行する。列数はステージごとに動的なので @css で生成。
fn board_view(game : @core.GameState, dispatch : (Msg) -> Unit) -> DomNode {
  let board = game.board
  let clickable = game.flips > 0 && !board.is_won()
  let cells : Array[DomNode] = []
  for y in 0..<board.height {
    for x in 0..<board.width {
      match board.get(x, y) {
        Some(cell) =>
          cells.push(
            div(
              class=cell_class(cell, clickable, board.width, board.height),
              on=events().click(_ => dispatch(Game(@core.Flip(x, y)))),
            ) <| [],
          )
        None => ()
      }
    }
  }
  let columns = @css.css(
    "grid-template-columns",
    "repeat(\{board.width}, max-content)",
  )
  div(
    class="board grid w-fit justify-center gap-1 rounded-2xl bg-[#d9d4c8] p-2 sm:gap-1.5 sm:p-3 \{columns}",
  ) <| cells
}

///|
/// ステージ番号とヒント。ヒントは高さを確保してステージ切替時のガタつきを防ぐ。
fn level_head_view(game : @core.GameState, level : @core.Level) -> DomNode {
  div(class="level-head") <| [
    h2(class="mt-1 text-sm font-semibold sm:text-base") <| [
      text("Stage \{game.level_index + 1}"),
    ],
    p(
      class="hint mx-auto min-h-8 max-w-md text-xs text-gray-500 sm:min-h-9 sm:text-sm",
    ) <| [
      text(level.hint),
    ],
  ]
}

///|
/// 残り反転回数とステップ数。
fn status_view(game : @core.GameState) -> DomNode {
  let badge = "badge rounded-full border border-gray-200 bg-white px-3 py-1 text-xs sm:text-[13px]"
  div(class="status flex flex-wrap justify-center gap-2") <| [
    span(class=badge) <| [
      text("反転 残り\{game.flips}"),
    ],
    span(class=badge) <| [
      text("ステップ \{game.steps}"),
    ],
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
/// 操作ボタン列。進める・やり直す。答えはトップバー側（「？」の隣）に置き、
/// ゲーム操作の並びで誤タップしないようにする。
fn controls_view(game : @core.GameState, dispatch : (Msg) -> Unit) -> DomNode {
  div(class="controls flex justify-center gap-2.5") <| [
    button(
      class=button_class(true),
      disabled=game.board.is_won(),
      on=events().click(_ => dispatch(Game(@core.Step))),
    ) <| [
      text("進める"),
    ],
    button(
      class=button_class(false),
      on=events().click(_ => dispatch(Game(@core.Reset))),
    ) <| [
      text("やり直す"),
    ],
  ]
}

///|
/// クリア・手詰まりのメッセージ。固定高さのスロットに出し、
/// 出現してもレイアウトが動かない（=スクロールが発生しない）ようにする。
fn message_view(game : @core.GameState, dispatch : (Msg) -> Unit) -> DomNode {
  let slot = "message-slot flex h-12 items-center justify-center gap-3"
  if game.board.is_won() {
    let last = game.level_index == @core.levels().length() - 1
    div(class=slot) <| [
      span(class="message won text-sm font-semibold sm:text-base") <| [
        text("クリア！"),
      ],
      button(
        class="next cursor-pointer rounded-full border-2 border-ink bg-white px-4 py-1.5 text-xs text-ink sm:text-sm",
        on=events().click(_ => dispatch(Next)),
      ) <| [
        text(
          if last {
            "ステージ選択へ"
          } else {
            "つぎのステージへ"
          },
        ),
      ],
    ]
  } else if game.is_stuck() {
    div(class=slot) <| [
      span(
        class="message stuck rounded-full bg-gray-200 px-4 py-1.5 text-xs text-gray-600 sm:text-sm",
      ) <| [
        text("これ以上変化しない。「やり直す」でもう一度"),
      ],
    ]
  } else {
    div(class=slot) <| []
  }
}

///|
/// モーダルの共通の器。背景クリックか「×」で閉じる。
fn modal_frame(
  title : String,
  body : Array[DomNode],
  dispatch : (Msg) -> Unit,
) -> DomNode {
  let children = [
      div(class="mb-1 flex items-center justify-between") <| [
        h2(class="text-base font-semibold") <| [
          text(title),
        ],
        button(
          class="close \{icon_button_class()}",
          on=events().click(_ => dispatch(CloseModal)),
        ) <| [
          text("×"),
        ],
      ],
    ] +
    body
  div(
    class="modal-backdrop fixed inset-0 z-10 flex items-center justify-center bg-black/40 p-4",
    on=events().click(_ => dispatch(CloseModal)),
  ) <| [
    div(
      class="modal max-h-[80dvh] w-full max-w-md overflow-y-auto rounded-2xl bg-white p-5 text-left",
      on=events().click(e => e.stopPropagation()),
    ) <| children,
  ]
}

///|
/// あそびかたモーダル。
fn rules_modal(dispatch : (Msg) -> Unit) -> DomNode {
  let para = "my-2 text-sm text-gray-600"
  modal_frame(
    "あそびかた",
    [
      p(class="text-xs text-gray-400") <| [
        text("白と黒の反転パズル"),
      ],
      p(class=para) <| [
        text(
          "マスをタップすると白黒が反転する（反転できる回数を1消費）。",
        ),
      ],
      p(class=para) <| [
        text(
          "「進める」を押すと、すべてのマスが同時に「自分と上下左右をあわせた5マスで多いほうの色」に変わる。" +
          "同数なら変わらない。孤立した白は黒に戻されてしまうが、囲まれた黒は連鎖して白くなっていく。",
        ),
      ],
      p(class=para) <| [
        text(
          "枠が二重のマスは固定マス。反転もステップも受け付けないが、まわりの色数えには入る。" +
          "固定黒以外のすべてのマスを白にすればクリアだ。",
        ),
      ],
      p(class=para) <| [
        text(
          "どのステージも、ちょうどの反転回数でクリアできることが保証されている。困ったら「答え」を見よう。",
        ),
      ],
    ],
    dispatch,
  )
}

///|
/// 答えモーダルのミニ盤面のマス。★が反転するマス。
fn answer_cell(cell : @core.Cell, marked : Bool) -> DomNode {
  let size = @css.styles([
    ("width", "1.75rem"),
    ("height", "1.75rem"),
    ("border-radius", "0.5rem"),
    ("display", "flex"),
    ("align-items", "center"),
    ("justify-content", "center"),
    ("font-size", "0.8125rem"),
  ])
  let face = cell_face(cell.color, cell.fixed)
  // 反転するのは黒マスなので、白い★と白の内枠で目立たせる
  let mark = if marked {
    " " +
    @css.styles([
      ("box-shadow", "inset 0 0 0 2px #ffffff"),
      ("color", "#ffffff"),
    ])
  } else {
    ""
  }
  let marker = if marked { " target" } else { "" }
  div(class="mini-cell\{marker} \{size} \{face}\{mark}") <| [
    text(if marked { "★" } else { "" }),
  ]
}

///|
/// 答えを見る前の確認モーダル。誤タップでネタバレしないためのワンクッション。
fn answer_confirm_modal(dispatch : (Msg) -> Unit) -> DomNode {
  modal_frame(
    "答えを見ますか？",
    [
      p(class="my-2 text-sm text-gray-600") <| [
        text("本当に答えを見ますか？"),
      ],
      div(class="mt-4 flex justify-end gap-2.5") <| [
        button(
          class="cancel-answer \{button_class(false)}",
          on=events().click(_ => dispatch(CloseModal)),
        ) <| [
          text("やめておく"),
        ],
        button(
          class="show-answer \{button_class(true)}",
          on=events().click(_ => dispatch(ShowAnswer)),
        ) <| [
          text("答えを見る"),
        ],
      ],
    ],
    dispatch,
  )
}

///|
/// 答えモーダル。反転するマスを★で示したミニ盤面を出す。
fn answer_modal(level : @core.Level, dispatch : (Msg) -> Unit) -> DomNode {
  let board = @core.parse(level.rows)
  let cells : Array[DomNode] = []
  for y in 0..<board.height {
    for x in 0..<board.width {
      match board.get(x, y) {
        Some(cell) => {
          let mut marked = false
          for pos in level.solution {
            let (sx, sy) = pos
            if sx == x && sy == y {
              marked = true
            }
          }
          cells.push(answer_cell(cell, marked))
        }
        None => ()
      }
    }
  }
  let columns = @css.css(
    "grid-template-columns",
    "repeat(\{board.width}, max-content)",
  )
  modal_frame(
    "答え",
    [
      p(class="my-2 text-sm text-gray-600") <| [
        text(
          "★のマス（\{level.budget}か所）を反転してから、「進める」をくり返す。",
        ),
      ],
      div(
        class="answer-board my-3 grid w-fit gap-1 rounded-xl bg-[#d9d4c8] p-2 \{columns}",
      ) <| cells,
      p(class="text-xs text-gray-400") <| [
        text("答えはひとつとはかぎらない"),
      ],
    ],
    dispatch,
  )
}

///|
/// プレイ画面。盤面が flex-1 の中央に座る。
fn play_view(
  state : AppState,
  game : @core.GameState,
  dispatch : (Msg) -> Unit,
) -> DomNode {
  let level = @core.levels()[game.level_index]
  let back = button(
    class="back cursor-pointer text-sm text-gray-400 hover:text-ink",
    on=events().click(_ => dispatch(Back)),
  ) <| [
    text("←"),
  ]
  let answer = button(
    class="answer h-8 cursor-pointer rounded-full border border-gray-300 bg-white px-3 text-xs text-gray-600",
    on=events().click(_ => dispatch(OpenAnswer)),
  ) <| [
    text("答え"),
  ]
  div(class="play flex h-full flex-col") <| [
    topbar_view(back, [answer], dispatch),
    level_head_view(game, level),
    status_view(game),
    div(class="flex min-h-0 flex-1 items-center justify-center") <| [
      board_view(game, dispatch),
    ],
    controls_view(game, dispatch),
    message_view(game, dispatch),
    match state.modal {
      Answer => answer_modal(level, dispatch)
      AnswerConfirm => answer_confirm_modal(dispatch)
      _ => fragment([])
    },
  ]
}

///|
/// アプリ全体のビュー。h-dvh の縦 flex に収める。
pub fn app_view(state : AppState, dispatch : (Msg) -> Unit) -> DomNode {
  div(
    class="app mx-auto flex h-full max-w-3xl flex-col px-3 py-2 text-center sm:px-4",
  ) <| [
    match state.screen {
      Select => select_view(state, dispatch)
      Play(game) => play_view(state, game, dispatch)
    },
    if state.modal == Rules {
      rules_modal(dispatch)
    } else {
      fragment([])
    },
  ]
}
