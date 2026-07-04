///|
/// テスト用の小さなステージ。
fn tiny_level() -> @core.Level {
  @core.Level::{
    hint: "テスト用",
    rows: ["wwww", "wbbw", "wbbw", "wwww"],
    budget: 1,
    solution: [(1, 1)],
  }
}

///|
fn tiny_state() -> @core.GameState {
  @core.state_of(tiny_level(), 0)
}

///|
test "state_of: ステージから初期状態を作る" {
  let state = tiny_state()
  @debug.assert_eq(state.board, @core.parse(["wwww", "wbbw", "wbbw", "wwww"]))
  @debug.assert_eq(state.flips, 1)
  @debug.assert_eq(state.steps, 0)
  @debug.assert_eq(state.level_index, 0)
}

///|
test "update Flip: 残り回数を1消費して反転する" {
  let state = tiny_state()
  let next = @core.update(state, Flip(1, 1))
  @debug.assert_eq(
    next.board.get(1, 1),
    Some(@core.Cell::{ color: White, fixed: false }),
  )
  @debug.assert_eq(next.flips, 0)
  // 元の状態は不変
  @debug.assert_eq(state.flips, 1)
}

///|
test "update Flip: 残り回数が無ければ何も起きない" {
  let state = tiny_state()
  let spent = @core.update(state, Flip(1, 1))
  let blocked = @core.update(spent, Flip(2, 1))
  @debug.assert_eq(blocked, spent)
}

///|
test "update Flip: 固定マス・盤外には効かない" {
  let level = @core.Level::{
    hint: "",
    rows: ["Bw", "wb"],
    budget: 3,
    solution: [],
  }
  let state = @core.state_of(level, 0)
  @debug.assert_eq(@core.update(state, Flip(0, 0)), state)
  @debug.assert_eq(@core.update(state, Flip(9, 9)), state)
}

///|
test "update Step: 1ステップ進めてカウントする" {
  let state = tiny_state()
  let next = @core.update(@core.update(state, Flip(1, 1)), Step)
  @debug.assert_eq(next.board, @core.parse(["wwww", "wwww", "wwbw", "wwww"]))
  @debug.assert_eq(next.steps, 1)
}

///|
test "update: クリア後は操作を受け付けない" {
  let state = tiny_state()
  // 1マス反転して2ステップ進めると全部白になる
  let won = @core.update(
    @core.update(@core.update(state, Flip(1, 1)), Step),
    Step,
  )
  @debug.assert_eq(won.board.is_won(), true)
  @debug.assert_eq(@core.update(won, Step), won)
  @debug.assert_eq(@core.update(won, Flip(0, 0)), won)
}

///|
test "update Reset: 初期状態に戻る" {
  let state = tiny_state()
  let played = @core.update(@core.update(state, Flip(1, 1)), Step)
  @debug.assert_eq(@core.update(played, Reset), state)
}

///|
test "update Select: ステージを切り替える。範囲外は無視" {
  let state = @core.initial_state(0)
  let second = @core.update(state, Select(1))
  @debug.assert_eq(second.level_index, 1)
  @debug.assert_eq(second, @core.initial_state(1))
  @debug.assert_eq(@core.update(state, Select(-1)), state)
  @debug.assert_eq(@core.update(state, Select(999)), state)
}

///|
test "stuck: 残り回数ゼロかつ盤面が動かず未クリアなら手詰まり" {
  let level = @core.Level::{
    hint: "",
    rows: ["ww", "bb"],
    budget: 0,
    solution: [],
  }
  let state = @core.state_of(level, 0)
  @debug.assert_eq(state.is_stuck(), true)
  let winnable = tiny_state()
  @debug.assert_eq(winnable.is_stuck(), false)
}

///|
test "levels: 50ステージあり、すべて正しく初期化できる" {
  @debug.assert_eq(@core.levels().length(), 50)
  for i in 0..<@core.levels().length() {
    let state = @core.initial_state(i)
    @debug.assert_eq(state.board.width > 0, true)
    @debug.assert_eq(state.board.is_won(), false)
  }
}
