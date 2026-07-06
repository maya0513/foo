///|
test "hash2: 同一入力は同一出力（決定性）" {
  @debug.assert_eq(@core.hash2(1U, 2, 3), @core.hash2(1U, 2, 3))
  @debug.assert_eq(@core.hash2(42U, -7, 100), @core.hash2(42U, -7, 100))
}

///|
test "hash2: 隣接座標・別シードで値が変わる" {
  assert_true(@core.hash2(1U, 2, 3) != @core.hash2(1U, 3, 3))
  assert_true(@core.hash2(1U, 2, 3) != @core.hash2(1U, 2, 4))
  assert_true(@core.hash2(1U, 2, 3) != @core.hash2(2U, 2, 3))
}

///|
test "hash3: 第3成分でも値が変わる" {
  assert_true(@core.hash3(1U, 2, 3, 0) != @core.hash3(1U, 2, 3, 1))
  @debug.assert_eq(@core.hash3(1U, 2, 3, 0), @core.hash3(1U, 2, 3, 0))
}

///|
test "to_unit: [0,1) に収まる" {
  for i = 0; i < 100; i = i + 1 {
    let u = @core.to_unit(@core.hash2(7U, i, i * 31))
    assert_true(u >= 0.0)
    assert_true(u < 1.0)
  }
}

///|
test "to_unit: 分布が偏りすぎない（平均が 0.5 付近）" {
  let mut sum = 0.0
  let n = 1000
  for i = 0; i < n; i = i + 1 {
    sum = sum + @core.to_unit(@core.hash2(7U, i, -i))
  }
  let mean = sum / n.to_double()
  assert_true(mean > 0.45)
  assert_true(mean < 0.55)
}
