///|
/// マスの色。目標は固定黒以外をすべて White にすること。
pub(all) enum Color {
  White
  Black
} derive(Eq, Debug)

///|
/// 反対の色。
pub fn Color::flipped(self : Color) -> Color {
  match self {
    White => Black
    Black => White
  }
}

///|
/// 盤面の1マス。fixed は固定マスで、反転もステップも受け付けないが、
/// まわりの色数えには入る。
pub(all) struct Cell {
  color : Color
  fixed : Bool
} derive(Eq, Debug)

///|
/// 盤面。cells は行優先（index = y * width + x）の不変データ。
pub(all) struct Board {
  width : Int
  height : Int
  cells : Array[Cell]
} derive(Eq, Debug)

///|
/// 文字列表記から盤面を作る。w=白 b=黒 W=固定白 B=固定黒。
pub fn parse(rows : Array[String]) -> Board {
  let height = rows.length()
  let width = if height == 0 { 0 } else { rows[0].char_length() }
  let cells : Array[Cell] = []
  for row in rows {
    for ch in row {
      let cell = match ch {
        'w' => Cell::{ color: White, fixed: false }
        'b' => Cell::{ color: Black, fixed: false }
        'W' => Cell::{ color: White, fixed: true }
        'B' => Cell::{ color: Black, fixed: true }
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
      let ch = match (cell.color, cell.fixed) {
        (White, false) => 'w'
        (Black, false) => 'b'
        (White, true) => 'W'
        (Black, true) => 'B'
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
/// 自分+隣接4マスの色を数える。返り値は (白, 黒)。
fn Board::tally(self : Board, x : Int, y : Int) -> (Int, Int) {
  let mut white = 0
  let mut black = 0
  let neighbors = [(x, y), (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
  for pos in neighbors {
    let (nx, ny) = pos
    match self.get(nx, ny) {
      Some(cell) =>
        match cell.color {
          White => white += 1
          Black => black += 1
        }
      None => ()
    }
  }
  (white, black)
}

///|
/// 1マスの次の状態。固定マスは不変。それ以外は自分+隣接で多いほうの色に変わり、
/// 同数なら現状維持。
fn Board::next_cell(self : Board, x : Int, y : Int) -> Cell {
  let cell = self.cells[y * self.width + x]
  if cell.fixed {
    cell
  } else {
    let (white, black) = self.tally(x, y)
    if white > black {
      { ..cell, color: White }
    } else if black > white {
      { ..cell, color: Black }
    } else {
      cell
    }
  }
}

///|
/// 1ステップ進める。全マスが同時に「自分+隣接で多いほうの色」に変わる。
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
/// 1マスの白黒を反転した新しい盤面を返す。固定マス・盤外は元のまま。
pub fn Board::toggle(self : Board, x : Int, y : Int) -> Board {
  match self.get(x, y) {
    Some(cell) if !cell.fixed => {
      let cells = self.cells.copy()
      cells[y * self.width + x] = { ..cell, color: cell.color.flipped() }
      { ..self, cells, }
    }
    _ => self
  }
}

///|
/// クリア判定。固定黒以外のすべてのマスが白ならクリア。
pub fn Board::is_won(self : Board) -> Bool {
  for cell in self.cells {
    if !cell.fixed && cell.color == Black {
      return false
    }
  }
  true
}
