///|
/// ステージ検証用の総当たりソルバー。
/// 「先に k マスを反転してからステップを進めるだけ」で勝てるかを調べる。
/// プレイヤーは反転とステップを交互にもできるが、これは十分条件になる。

///|
/// 現在の盤面からステップを進めるだけで勝てるか。膠着したら打ち切る。
fn wins_by_stepping(board : @core.Board, max_steps : Int) -> Bool {
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
/// 反転できる候補（固定でない黒）の座標一覧。
fn black_positions(board : @core.Board) -> Array[(Int, Int)] {
  let positions : Array[(Int, Int)] = []
  for y in 0..<board.height {
    for x in 0..<board.width {
      match board.get(x, y) {
        Some(cell) if !cell.fixed && cell.color == Black =>
          positions.push((x, y))
        _ => ()
      }
    }
  }
  positions
}

///|
/// blacks[start..] から残り k マスを選んで反転し、勝てる組み合わせがあるか。
fn search(
  board : @core.Board,
  blacks : Array[(Int, Int)],
  start : Int,
  k : Int,
) -> Bool {
  if k == 0 {
    return wins_by_stepping(board, 60)
  }
  for i in start..<blacks.length() {
    let (x, y) = blacks[i]
    if search(board.toggle(x, y), blacks, i + 1, k - 1) {
      return true
    }
  }
  false
}

///|
/// 勝つのに必要な最小の反転回数（max まで探索）。
fn min_flips(board : @core.Board, max : Int) -> Int? {
  let blacks = black_positions(board)
  for k in 0..<=max {
    if search(board, blacks, 0, k) {
      return Some(k)
    }
  }
  None
}

///|
test "全ステージ: 初期盤面は膠着状態（勝手には動かない）" {
  let frozen : Array[(Int, Bool)] = []
  for i in 0..<@core.levels().length() {
    let board = @core.parse(@core.levels()[i].rows)
    frozen.push((i + 1, board.step() == board))
  }
  let expected : Array[(Int, Bool)] = []
  for i in 0..<@core.levels().length() {
    expected.push((i + 1, true))
  }
  @debug.assert_eq(frozen, expected)
}

///|
test "全ステージ: budget はソルバーが求めた最小の反転回数と一致する" {
  let minima : Array[(Int, Int?)] = []
  for i in 0..<@core.levels().length() {
    let level = @core.levels()[i]
    let board = @core.parse(level.rows)
    minima.push((i + 1, min_flips(board, level.budget)))
  }
  let expected : Array[(Int, Int?)] = []
  for i in 0..<@core.levels().length() {
    expected.push((i + 1, Some(@core.levels()[i].budget)))
  }
  @debug.assert_eq(minima, expected)
}

///|
test "全ステージ: solution は budget 回ちょうどで、実行すると勝てる" {
  let results : Array[(Int, Int, Bool)] = []
  for i in 0..<@core.levels().length() {
    let level = @core.levels()[i]
    let mut board = @core.parse(level.rows)
    for pos in level.solution {
      let (x, y) = pos
      board = board.toggle(x, y)
    }
    results.push((i + 1, level.solution.length(), wins_by_stepping(board, 60)))
  }
  let expected : Array[(Int, Int, Bool)] = []
  for i in 0..<@core.levels().length() {
    expected.push((i + 1, @core.levels()[i].budget, true))
  }
  @debug.assert_eq(results, expected)
}

///|
test "全ステージ: solution の座標はすべて盤上の（固定でない）黒マス" {
  for i in 0..<@core.levels().length() {
    let level = @core.levels()[i]
    let board = @core.parse(level.rows)
    for pos in level.solution {
      let (x, y) = pos
      match board.get(x, y) {
        Some(cell) => {
          @debug.assert_eq(cell.fixed, false)
          @debug.assert_eq(cell.color, @core.Color::Black)
        }
        None => abort("solution out of board: stage \{i + 1} (\{x}, \{y})")
      }
    }
  }
}
