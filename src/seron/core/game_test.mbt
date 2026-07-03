///|
/// テスト用の小さなレベル。
fn tiny_level() -> @core.Level {
  @core.Level::{
    name: "テスト",
    intro: "テスト用",
    rows: ["bbbb", "brrb", "brrb", "bbbb"],
    budget: 1,
  }
}

///|
fn tiny_state() -> @core.GameState {
  @core.state_of(tiny_level(), 0)
}

///|
test "state_of: レベルから初期状態を作る" {
  let state = tiny_state()
  @debug.assert_eq(state.board, @core.parse(["bbbb", "brrb", "brrb", "bbbb"]))
  @debug.assert_eq(state.points_left, 1)
  @debug.assert_eq(state.steps, 0)
  @debug.assert_eq(state.level_index, 0)
}

///|
test "update Persuade: 持ち点を消費して1人説得する" {
  let state = tiny_state()
  let next = @core.update(state, Persuade(1, 1))
  @debug.assert_eq(
    next.board.get(1, 1),
    Some(@core.Cell::{ color: Blue, stubborn: false }),
  )
  @debug.assert_eq(next.points_left, 0)
  // 元の状態は不変
  @debug.assert_eq(state.points_left, 1)
}

///|
test "update Persuade: 持ち点が無ければ何も起きない" {
  let state = tiny_state()
  let spent = @core.update(state, Persuade(1, 1))
  let blocked = @core.update(spent, Persuade(2, 1))
  @debug.assert_eq(blocked, spent)
}

///|
test "update Persuade: 頑固者・盤外には効かない" {
  let level = @core.Level::{
    name: "頑固",
    intro: "",
    rows: ["Rb", "br"],
    budget: 3,
  }
  let state = @core.state_of(level, 0)
  @debug.assert_eq(@core.update(state, Persuade(0, 0)), state)
  @debug.assert_eq(@core.update(state, Persuade(9, 9)), state)
}

///|
test "update Advance: 議論を1ステップ進めてカウントする" {
  let state = tiny_state()
  let next = @core.update(@core.update(state, Persuade(1, 1)), Advance)
  @debug.assert_eq(next.board, @core.parse(["bbbb", "bbbb", "bbrb", "bbbb"]))
  @debug.assert_eq(next.steps, 1)
}

///|
test "update: 勝利後は操作を受け付けない" {
  let state = tiny_state()
  // 1人説得して2回進めると全員賛成になる
  let won = @core.update(
    @core.update(@core.update(state, Persuade(1, 1)), Advance),
    Advance,
  )
  @debug.assert_eq(won.board.is_won(), true)
  @debug.assert_eq(@core.update(won, Advance), won)
  @debug.assert_eq(@core.update(won, Persuade(0, 0)), won)
}

///|
test "update Reset: 初期状態に戻る" {
  let state = tiny_state()
  let played = @core.update(@core.update(state, Persuade(1, 1)), Advance)
  @debug.assert_eq(@core.update(played, Reset), state)
}

///|
test "update Select: レベルを切り替える。範囲外は無視" {
  let state = @core.initial_state(0)
  let second = @core.update(state, Select(1))
  @debug.assert_eq(second.level_index, 1)
  @debug.assert_eq(second, @core.initial_state(1))
  @debug.assert_eq(@core.update(state, Select(-1)), state)
  @debug.assert_eq(@core.update(state, Select(999)), state)
}

///|
test "stuck: 持ち点ゼロかつ盤面が動かず未勝利なら手詰まり" {
  let level = @core.Level::{ name: "詰み", intro: "", rows: ["bb", "rr"], budget: 0 }
  let state = @core.state_of(level, 0)
  @debug.assert_eq(state.is_stuck(), true)
  let winnable = tiny_state()
  @debug.assert_eq(winnable.is_stuck(), false)
}

///|
test "levels: すべてのレベルは正しく初期化できる" {
  @debug.assert_eq(@core.levels().length() >= 4, true)
  for i in 0..<@core.levels().length() {
    let state = @core.initial_state(i)
    @debug.assert_eq(state.board.width > 0, true)
    @debug.assert_eq(state.board.is_won(), false)
  }
}
