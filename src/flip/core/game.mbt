///|
/// ステージ定義。rows は盤面の文字列表記、budget は反転できる回数、
/// solution は budget 回ちょうどで勝てる答えの一例（反転する座標の列）。
/// hint はルールを学ぶための一言（不要なステージは空文字）。
pub(all) struct Level {
  hint : String
  rows : Array[String]
  budget : Int
  solution : Array[(Int, Int)]
} derive(Eq, Debug)

///|
/// ゲームの状態。すべて不変データで、update が新しい状態を返す。
pub(all) struct GameState {
  level_index : Int
  board : Board
  flips : Int
  steps : Int
} derive(Eq, Debug)

///|
/// プレイヤーの操作。Flip はマスの白黒を反転（残り回数を1消費）、
/// Step は盤面を1ステップ進める。
pub(all) enum Action {
  Flip(Int, Int)
  Step
  Reset
  Select(Int)
} derive(Eq, Debug)

///|
/// ステージから初期状態を作る。
pub fn state_of(level : Level, index : Int) -> GameState {
  {
    level_index: index,
    board: parse(level.rows),
    flips: level.budget,
    steps: 0,
  }
}

///|
/// ステージ番号から初期状態を作る。
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
    Flip(x, y) => {
      let toggled = state.board.toggle(x, y)
      if state.flips > 0 && toggled != state.board {
        { ..state, board: toggled, flips: state.flips - 1 }
      } else {
        state
      }
    }
    Step => { ..state, board: state.board.step(), steps: state.steps + 1 }
  }
}

///|
/// 手詰まり判定。反転回数ゼロ・盤面は膠着・未クリアならリセットするしかない。
pub fn GameState::is_stuck(self : GameState) -> Bool {
  self.flips == 0 && !self.board.is_won() && self.board.step() == self.board
}
