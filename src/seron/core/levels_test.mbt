///|
/// レベル検証用の総当たりソルバー。
/// 「先に k 人を説得してから議論を進めるだけ」で勝てるかを調べる。
/// プレイヤーは説得とステップを交互にもできるが、これは十分条件になる。

///|
/// 現在の盤面から議論を進めるだけで勝てるか。膠着したら打ち切る。
fn wins_by_advancing(board : @core.Board, max_steps : Int) -> Bool {
  let mut b = board
  if b.is_won() {
    return true
  }
  for _ in 0..<max_steps {
    let next = b.step()
    if next.is_won() {
      return true
    }
    if next == b {
      return false
    }
    b = next
  }
  false
}

///|
/// 説得候補（頑固でない反対派）の座標一覧。
fn red_positions(board : @core.Board) -> Array[(Int, Int)] {
  let positions : Array[(Int, Int)] = []
  for y in 0..<board.height {
    for x in 0..<board.width {
      match board.get(x, y) {
        Some(cell) if !(cell.stubborn) && cell.color == Red =>
          positions.push((x, y))
        _ => ()
      }
    }
  }
  positions
}

///|
/// reds[start..] から残り k 人を選んで説得し、勝てる組み合わせがあるか。
fn search(
  board : @core.Board,
  reds : Array[(Int, Int)],
  start : Int,
  k : Int,
) -> Bool {
  if k == 0 {
    return wins_by_advancing(board, 40)
  }
  for i in start..<reds.length() {
    let (x, y) = reds[i]
    if search(board.toggle(x, y), reds, i + 1, k - 1) {
      return true
    }
  }
  false
}

///|
/// 勝つのに必要な最小説得人数（max まで探索）。
fn min_persuasions(board : @core.Board, max : Int) -> Int? {
  let reds = red_positions(board)
  for k in 0..=max {
    if search(board, reds, 0, k) {
      return Some(k)
    }
  }
  None
}

///|
test "全レベル: 初期盤面は膠着状態（勝手には動かない）" {
  let frozen : Array[(String, Bool)] = []
  for level in @core.levels() {
    let board = @core.parse(level.rows)
    frozen.push((level.name, board.step() == board))
  }
  let expected : Array[(String, Bool)] = []
  for level in @core.levels() {
    expected.push((level.name, true))
  }
  @debug.assert_eq(frozen, expected)
}

///|
test "全レベル: budget はソルバーが求めた最小説得人数と一致する" {
  let minima : Array[(String, Int?)] = []
  for level in @core.levels() {
    let board = @core.parse(level.rows)
    minima.push((level.name, min_persuasions(board, level.budget + 2)))
  }
  let expected : Array[(String, Int?)] = []
  for level in @core.levels() {
    expected.push((level.name, Some(level.budget)))
  }
  @debug.assert_eq(minima, expected)
}
