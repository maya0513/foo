///|
/// レベル定義。rows は盤面の文字列表記、budget は持ち点（説得できる人数）。
pub(all) struct Level {
  name : String
  intro : String
  rows : Array[String]
  budget : Int
} derive(Eq, Debug)

///|
/// ゲームの状態。すべて不変データで、update が新しい状態を返す。
pub(all) struct GameState {
  level_index : Int
  board : Board
  points_left : Int
  steps : Int
} derive(Eq, Debug)

///|
/// プレイヤーの操作。
pub(all) enum Action {
  Persuade(Int, Int)
  Advance
  Reset
  Select(Int)
} derive(Eq, Debug)

///|
/// レベルから初期状態を作る。
pub fn state_of(level : Level, index : Int) -> GameState {
  {
    level_index: index,
    board: parse(level.rows),
    points_left: level.budget,
    steps: 0,
  }
}

///|
/// レベル番号から初期状態を作る。
pub fn initial_state(index : Int) -> GameState {
  state_of(levels()[index], index)
}

///|
/// 操作を適用して新しい状態を返す純関数。無効な操作は状態をそのまま返す。
pub fn update(state : GameState, action : Action) -> GameState {
  match action {
    Select(i) =>
      if i >= 0 && i < levels().length() {
        initial_state(i)
      } else {
        state
      }
    Reset => initial_state(state.level_index)
    _ if state.board.is_won() => state
    Persuade(x, y) => {
      let toggled = state.board.toggle(x, y)
      if state.points_left > 0 && toggled != state.board {
        { ..state, board: toggled, points_left: state.points_left - 1 }
      } else {
        state
      }
    }
    Advance => { ..state, board: state.board.step(), steps: state.steps + 1 }
  }
}

///|
/// 手詰まり判定。持ち点ゼロ・盤面は膠着・未勝利ならリセットするしかない。
pub fn GameState::is_stuck(self : GameState) -> Bool {
  self.points_left == 0 &&
  !(self.board.is_won()) &&
  self.board.step() == self.board
}
