///|
test "stage_query は 0始まりの index から 1始まりの ?stage=N を作る" {
  @debug.assert_eq(stage_query(0), "?stage=1")
  @debug.assert_eq(stage_query(4), "?stage=5")
}

///|
test "parse_stage は ?stage=N を 0始まりの index として読む" {
  @debug.assert_eq(parse_stage("?stage=1", 30), Some(0))
  @debug.assert_eq(parse_stage("?stage=30", 30), Some(29))
}

///|
test "parse_stage: プレフィックス不一致・空・範囲外・不正値は None" {
  @debug.assert_eq(parse_stage("", 30), None)
  @debug.assert_eq(parse_stage("?stage=", 30), None)
  @debug.assert_eq(parse_stage("?other=1", 30), None)
  @debug.assert_eq(parse_stage("?stage=0", 30), None)
  @debug.assert_eq(parse_stage("?stage=31", 30), None)
  @debug.assert_eq(parse_stage("?stage=abc", 30), None)
  @debug.assert_eq(parse_stage("?stage=1a", 30), None)
  @debug.assert_eq(parse_stage("?stage=-1", 30), None)
}
