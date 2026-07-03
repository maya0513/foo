///|
/// 盤面表記: b=賛成(青) r=反対(赤) B=頑固な賛成 R=頑固な反対

///|
test "parse は寸法とセルを読み取り、to_rows で往復できる" {
  let board = @core.parse(["br", "Bb", "rR"])
  @debug.assert_eq(board.width, 2)
  @debug.assert_eq(board.height, 3)
  @debug.assert_eq(board.get(0, 0), Some(@core.Cell::{ color: Blue, stubborn: false }))
  @debug.assert_eq(board.get(1, 0), Some(@core.Cell::{ color: Red, stubborn: false }))
  @debug.assert_eq(board.get(0, 1), Some(@core.Cell::{ color: Blue, stubborn: true }))
  @debug.assert_eq(board.get(1, 2), Some(@core.Cell::{ color: Red, stubborn: true }))
  @debug.assert_eq(board.get(2, 0), None)
  @debug.assert_eq(board.get(0, -1), None)
  @debug.assert_eq(board.to_rows(), ["br", "Bb", "rR"])
}

///|
/// 中央のマスは自分+隣接4の5票。反対3票で寝返る。
test "step: 3方を囲まれた内部のマスは多数派に転向する" {
  let board = @core.parse(["bbb", "brb", "bbb"])
  // 中央 r: 隣接4がすべて b → 転向
  @debug.assert_eq(board.step().to_rows(), ["bbb", "bbb", "bbb"])
}

///|
test "step: 内部のマスは隣接2票では転向しない（2x2ブロックは安定）" {
  let board = @core.parse(["bbbb", "brrb", "brrb", "bbbb"])
  @debug.assert_eq(board.step(), board)
}

///|
test "step: まっすぐな境界は膠着する" {
  let board = @core.parse(["bbb", "bbb", "rrr", "rrr"])
  @debug.assert_eq(board.step(), board)
}

///|
test "step: 孤立した出っ張りは同調圧力で押し戻される" {
  // 赤の海に説得した1人 → 隣接4がすべて r なので戻ってしまう
  let board = @core.parse(["rrr", "rbr", "rrr"])
  @debug.assert_eq(board.step().to_rows(), ["rrr", "rrr", "rrr"])
}

///|
test "step: 行き止まりの1マス幅の溝は奥から順に埋まる" {
  // 幅1の赤い溝（下が青で行き止まり）: 溝尻は隣接3が青 → 1ステップごとに1マス埋まる
  let board = @core.parse(["brb", "brb", "bbb"])
  @debug.assert_eq(board.step().to_rows(), ["brb", "bbb", "bbb"])
  @debug.assert_eq(board.step().step().to_rows(), ["bbb", "bbb", "bbb"])
}

///|
test "step: 角のマスは両隣が反対なら転向する" {
  let board = @core.parse(["rb", "bb"])
  @debug.assert_eq(board.step().to_rows(), ["bb", "bb"])
}

///|
test "step: 辺のマスは隣接3すべてが反対のときだけ転向する" {
  // 上辺中央の r: 隣接は左b・右b・下b → 転向
  let fill = @core.parse(["brb", "bbb"])
  @debug.assert_eq(fill.step().to_rows(), ["bbb", "bbb"])
  // 上辺中央の r: 隣接は左b・右r・下b → 2対2 の同数で現状維持
  let stay = @core.parse(["brr", "bbb"])
  @debug.assert_eq(
    stay.step().get(1, 0),
    Some(@core.Cell::{ color: Red, stubborn: false }),
  )
}

///|
test "step: 頑固者は転向しないが票としては数えられる" {
  // 中央の R は青4に囲まれても赤のまま
  let board = @core.parse(["bbb", "bRb", "bbb"])
  @debug.assert_eq(board.step(), board)
  // 頑固な B の票で周囲の r が転向する（溝尻と同じ形）
  let anchored = @core.parse(["rrr", "BrB", "bbb"])
  // (1,1) の r: 隣接 = B(左) B(右) r(上) b(下) → 青3対赤2 → 転向
  @debug.assert_eq(
    anchored.step().get(1, 1),
    Some(@core.Cell::{ color: Blue, stubborn: false }),
  )
}

///|
test "toggle: 普通のマスは色が反転し、元の盤面は変わらない" {
  let board = @core.parse(["rb"])
  let flipped = board.toggle(0, 0)
  @debug.assert_eq(flipped.to_rows(), ["bb"])
  @debug.assert_eq(board.to_rows(), ["rb"])
  @debug.assert_eq(flipped.toggle(1, 0).to_rows(), ["br"])
}

///|
test "toggle: 頑固者と盤外は変化しない" {
  let board = @core.parse(["Rb"])
  @debug.assert_eq(board.toggle(0, 0), board)
  @debug.assert_eq(board.toggle(5, 5), board)
}

///|
test "is_won: 説得可能な全員が青なら勝ち（頑固な反対派は数えない）" {
  @debug.assert_eq(@core.parse(["bb", "bb"]).is_won(), true)
  @debug.assert_eq(@core.parse(["bb", "br"]).is_won(), false)
  @debug.assert_eq(@core.parse(["bb", "bR"]).is_won(), true)
  @debug.assert_eq(@core.parse(["Bb", "bb"]).is_won(), true)
}
