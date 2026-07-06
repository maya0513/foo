///|
test "value_noise2: 決定性" {
  @debug.assert_eq(
    @core.value_noise2(1U, 1.5, 2.5),
    @core.value_noise2(1U, 1.5, 2.5),
  )
}

///|
test "value_noise2: 格子点上では格子値と一致する" {
  @debug.assert_eq(
    @core.value_noise2(9U, 3.0, 5.0),
    @core.lattice_value(9U, 3, 5),
  )
  @debug.assert_eq(
    @core.value_noise2(9U, -2.0, 0.0),
    @core.lattice_value(9U, -2, 0),
  )
}

///|
test "value_noise2: 近傍で連続（小さな差分は小さな変化）" {
  let a = @core.value_noise2(3U, 10.25, -4.75)
  let b = @core.value_noise2(3U, 10.251, -4.75)
  assert_true((a - b).abs() < 0.05)
}

///|
test "value_noise2: 値域は [-1,1]" {
  for i = 0; i < 400; i = i + 1 {
    let x = (i % 20).to_double() * 0.37 - 3.0
    let z = (i / 20).to_double() * 0.53 - 5.0
    let v = @core.value_noise2(5U, x, z)
    assert_true(v >= -1.0)
    assert_true(v <= 1.0)
  }
}

///|
test "value_noise2: シードを変えると場が変わる" {
  assert_true(
    @core.value_noise2(1U, 1.5, 2.5) != @core.value_noise2(2U, 1.5, 2.5),
  )
}

///|
test "fbm2: octaves=1 は value_noise2 と一致する" {
  @debug.assert_eq(
    @core.fbm2(4U, 1.3, -2.7, 1, 2.0, 0.5),
    @core.value_noise2(4U, 1.3, -2.7),
  )
}

///|
test "fbm2: 値域は [-1,1] で決定的" {
  @debug.assert_eq(
    @core.fbm2(4U, 0.4, 0.9, 5, 2.0, 0.5),
    @core.fbm2(4U, 0.4, 0.9, 5, 2.0, 0.5),
  )
  for i = 0; i < 200; i = i + 1 {
    let x = (i % 20).to_double() * 0.71
    let z = (i / 20).to_double() * 0.29
    let v = @core.fbm2(8U, x, z, 5, 2.0, 0.5)
    assert_true(v >= -1.0)
    assert_true(v <= 1.0)
  }
}
