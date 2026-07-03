///|
/// 盤面表記: w=白 b=黒 W=固定白 B=固定黒

///|
test "parse は寸法とセルを読み取り、to_rows で往復できる" {
  let board = @core.parse(["wb", "Ww", "bB"])
  @debug.assert_eq(board.width, 2)
  @debug.assert_eq(board.height, 3)
  @debug.assert_eq(
    board.get(0, 0),
    Some(@core.Cell::{ color: White, fixed: false }),
  )
  @debug.assert_eq(
    board.get(1, 0),
    Some(@core.Cell::{ color: Black, fixed: false }),
  )
  @debug.assert_eq(
    board.get(0, 1),
    Some(@core.Cell::{ color: White, fixed: true }),
  )
  @debug.assert_eq(
    board.get(1, 2),
    Some(@core.Cell::{ color: Black, fixed: true }),
  )
  @debug.assert_eq(board.get(2, 0), None)
  @debug.assert_eq(board.get(0, -1), None)
  @debug.assert_eq(board.to_rows(), ["wb", "Ww", "bB"])
}

///|
/// 中央のマスは自分+隣接4の5マス。白3つで白に変わる。
test "step: 3方を白に囲まれた内部のマスは白になる" {
  let board = @core.parse(["www", "wbw", "www"])
  // 中央 b: 隣接4がすべて w → 白になる
  @debug.assert_eq(board.step().to_rows(), ["www", "www", "www"])
}

///|
test "step: 内部のマスは隣接2つでは変わらない（2x2の黒は安定）" {
  let board = @core.parse(["wwww", "wbbw", "wbbw", "wwww"])
  @debug.assert_eq(board.step(), board)
}

///|
test "step: まっすぐな境界は膠着する" {
  let board = @core.parse(["www", "www", "bbb", "bbb"])
  @debug.assert_eq(board.step(), board)
}

///|
test "step: 孤立した白は黒に押し戻される" {
  // 黒の海に1つだけ反転した白 → 隣接4がすべて b なので戻ってしまう
  let board = @core.parse(["bbb", "bwb", "bbb"])
  @debug.assert_eq(board.step().to_rows(), ["bbb", "bbb", "bbb"])
}

///|
test "step: 行き止まりの1マス幅の溝は奥から順に白くなる" {
  // 幅1の黒い溝（下が白で行き止まり）: 溝尻は隣接3が白 → 1ステップごとに1マス白くなる
  let board = @core.parse(["wbw", "wbw", "www"])
  @debug.assert_eq(board.step().to_rows(), ["wbw", "www", "www"])
  @debug.assert_eq(board.step().step().to_rows(), ["www", "www", "www"])
}

///|
test "step: 角のマスは両隣が白なら白になる" {
  let board = @core.parse(["bw", "ww"])
  @debug.assert_eq(board.step().to_rows(), ["ww", "ww"])
}

///|
test "step: 辺のマスは隣接3すべてが白のときだけ白になる" {
  // 上辺中央の b: 隣接は左w・右w・下w → 白になる
  let fill = @core.parse(["wbw", "www"])
  @debug.assert_eq(fill.step().to_rows(), ["www", "www"])
  // 上辺中央の b: 隣接は左w・右b・下w → 2対2 の同数で現状維持
  let stay = @core.parse(["wbb", "www"])
  @debug.assert_eq(
    stay.step().get(1, 0),
    Some(@core.Cell::{ color: Black, fixed: false }),
  )
}

///|
test "step: 固定マスは変わらないが数には入る" {
  // 中央の B は白4に囲まれても黒のまま
  let board = @core.parse(["www", "wBw", "www"])
  @debug.assert_eq(board.step(), board)
  // 固定白 W の数で隣の b が白になる（溝尻と同じ形）
  let anchored = @core.parse(["bbb", "WbW", "www"])
  // (1,1) の b: 隣接 = W(左) W(右) b(上) w(下) → 白3対黒2 → 白になる
  @debug.assert_eq(
    anchored.step().get(1, 1),
    Some(@core.Cell::{ color: White, fixed: false }),
  )
}

///|
test "toggle: 普通のマスは白黒が反転し、元の盤面は変わらない" {
  let board = @core.parse(["bw"])
  let flipped = board.toggle(0, 0)
  @debug.assert_eq(flipped.to_rows(), ["ww"])
  @debug.assert_eq(board.to_rows(), ["bw"])
  @debug.assert_eq(flipped.toggle(1, 0).to_rows(), ["wb"])
}

///|
test "toggle: 固定マスと盤外は変化しない" {
  let board = @core.parse(["Bw"])
  @debug.assert_eq(board.toggle(0, 0), board)
  @debug.assert_eq(board.toggle(5, 5), board)
}

///|
test "is_won: 固定黒以外がすべて白ならクリア（固定黒は数えない）" {
  @debug.assert_eq(@core.parse(["ww", "ww"]).is_won(), true)
  @debug.assert_eq(@core.parse(["ww", "wb"]).is_won(), false)
  @debug.assert_eq(@core.parse(["ww", "wB"]).is_won(), true)
  @debug.assert_eq(@core.parse(["Ww", "ww"]).is_won(), true)
}
