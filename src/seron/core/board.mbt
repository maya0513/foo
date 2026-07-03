///|
/// 意見の色。Blue が賛成、Red が反対。
pub(all) enum Color {
  Blue
  Red
} derive(Eq, Debug)

///|
/// 反対の色。
pub fn Color::flipped(self : Color) -> Color {
  match self {
    Blue => Red
    Red => Blue
  }
}

///|
/// 盤面の1マス（1人）。stubborn は頑固者で、説得も伝播も受け付けないが票は持つ。
pub(all) struct Cell {
  color : Color
  stubborn : Bool
} derive(Eq, Debug)

///|
/// 盤面。cells は行優先（index = y * width + x）の不変データ。
pub(all) struct Board {
  width : Int
  height : Int
  cells : Array[Cell]
} derive(Eq, Debug)

///|
/// 文字列表記から盤面を作る。b=賛成 r=反対 B=頑固な賛成 R=頑固な反対。
pub fn parse(rows : Array[String]) -> Board {
  let height = rows.length()
  let width = if height == 0 { 0 } else { rows[0].char_length() }
  let cells : Array[Cell] = []
  for row in rows {
    for ch in row {
      let cell = match ch {
        'b' => Cell::{ color: Blue, stubborn: false }
        'r' => Cell::{ color: Red, stubborn: false }
        'B' => Cell::{ color: Blue, stubborn: true }
        'R' => Cell::{ color: Red, stubborn: true }
        _ => abort("invalid cell char: \{ch}")
      }
      cells.push(cell)
    }
  }
  { width, height, cells }
}

///|
/// 盤面を文字列表記に戻す（テスト・デバッグ用）。
pub fn Board::to_rows(self : Board) -> Array[String] {
  let rows : Array[String] = []
  for y in 0..<self.height {
    let buf = StringBuilder::new()
    for x in 0..<self.width {
      let cell = self.cells[y * self.width + x]
      let ch = match (cell.color, cell.stubborn) {
        (Blue, false) => 'b'
        (Red, false) => 'r'
        (Blue, true) => 'B'
        (Red, true) => 'R'
      }
      buf.write_char(ch)
    }
    rows.push(buf.to_string())
  }
  rows
}

///|
/// 座標のマスを返す。盤外は None。
pub fn Board::get(self : Board, x : Int, y : Int) -> Cell? {
  if x < 0 || x >= self.width || y < 0 || y >= self.height {
    None
  } else {
    Some(self.cells[y * self.width + x])
  }
}

///|
/// 自分+隣接4マスの票を数える。返り値は (青票, 赤票)。
fn Board::votes(self : Board, x : Int, y : Int) -> (Int, Int) {
  let mut blue = 0
  let mut red = 0
  let neighbors = [(x, y), (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
  for pos in neighbors {
    let (nx, ny) = pos
    match self.get(nx, ny) {
      Some(cell) =>
        match cell.color {
          Blue => blue += 1
          Red => red += 1
        }
      None => ()
    }
  }
  (blue, red)
}

///|
/// 1マスの次の状態。頑固者は不変。それ以外は自分+隣接の多数派に従い、
/// 同数なら現状維持。
fn Board::next_cell(self : Board, x : Int, y : Int) -> Cell {
  let cell = self.cells[y * self.width + x]
  if cell.stubborn {
    cell
  } else {
    let (blue, red) = self.votes(x, y)
    if blue > red {
      { ..cell, color: Blue }
    } else if red > blue {
      { ..cell, color: Red }
    } else {
      cell
    }
  }
}

///|
/// 議論を1ステップ進める。全マスが同時に多数決で意見を更新する。
pub fn Board::step(self : Board) -> Board {
  let cells : Array[Cell] = []
  for y in 0..<self.height {
    for x in 0..<self.width {
      cells.push(self.next_cell(x, y))
    }
  }
  { ..self, cells, }
}

///|
/// 1人を説得して色を反転した新しい盤面を返す。頑固者・盤外は元のまま。
pub fn Board::toggle(self : Board, x : Int, y : Int) -> Board {
  match self.get(x, y) {
    Some(cell) if !(cell.stubborn) => {
      let cells = self.cells.copy()
      cells[y * self.width + x] = { ..cell, color: cell.color.flipped() }
      { ..self, cells, }
    }
    _ => self
  }
}

///|
/// 勝利判定。説得可能な全員が賛成（青）なら勝ち。頑固な反対派は数えない。
pub fn Board::is_won(self : Board) -> Bool {
  for cell in self.cells {
    if !(cell.stubborn) && cell.color == Red {
      return false
    }
  }
  true
}
