///|
test "site_title はサイト名を返す" {
  @debug.assert_eq(site_title(), "foo")
}

///|
test "games にフリップへのリンクがある" {
  @debug.assert_eq(games().map(g => g.1), ["/flip/"])
}
