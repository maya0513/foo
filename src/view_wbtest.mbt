///|
test "site_title はサイト名を返す" {
  @debug.assert_eq(site_title(), "foo")
}

///|
test "games にセロンへのリンクがある" {
  @debug.assert_eq(games().map(g => g.1), ["/seron/"])
}
