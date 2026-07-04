///|
test "update_app SyncRoute(Some(i)): 指定ステージのプレイ画面に同期する" {
  let cleared = Array::make(@core.levels().length(), false)
  let state = init_app(cleared)
  let next = update_app(state, SyncRoute(Some(2)))
  @debug.assert_eq(next.screen, Play(@core.initial_state(2)))
  @debug.assert_eq(next.modal, NoModal)
}

///|
test "update_app SyncRoute(None): ステージ選択画面に同期する" {
  let cleared = Array::make(@core.levels().length(), false)
  let state = { ..init_app(cleared), screen: Play(@core.initial_state(1)) }
  let next = update_app(state, SyncRoute(None))
  @debug.assert_eq(next.screen, Select)
}

///|
test "update_app SyncRoute: cleared には影響しない（history 専用の同期メッセージ）" {
  let cleared = Array::make(@core.levels().length(), false)
  cleared[0] = true
  let state = init_app(cleared)
  let next = update_app(state, SyncRoute(Some(1)))
  @debug.assert_eq(next.cleared, cleared)
}
