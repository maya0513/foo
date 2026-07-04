///|
/// URL とアプリの画面を対応させる。副作用（history の読み書き）はここに閉じ、
/// 純粋関数（stage_query / parse_stage）と分離する。
///
/// URL設計: `/flip/?stage=N`（1始まり）。クエリなし＝ステージ選択。
/// Cloudflare Workers の静的アセット配信はパス単位でしか解決せず SPA
/// フォールバックも無いため、`/flip/2/` のようなパスベース設計は404の
/// リスクがある。クエリなら常に同じ dist/flip/index.html に解決されるため安全。

///|
/// ステージ index（0始まり）から `?stage=N`（1始まり）を作る。
pub fn stage_query(index : Int) -> String {
  "?stage=\{index + 1}"
}

///|
/// location.search（例: "?stage=3"）から 0始まりのステージ index を読む。
/// プレフィックス不一致・数字以外の混入・空・範囲外はすべて None。
pub fn parse_stage(search : String, level_count : Int) -> Int? {
  let prefix = "?stage="
  if !(search.has_prefix(prefix)) {
    return None
  }
  let digits = prefix.length()
  if search.length() <= digits {
    return None
  }
  let mut n = 0
  let mut i = 0
  for ch in search {
    if i >= digits {
      if !(ch.is_ascii_digit()) {
        return None
      }
      n = n * 10 + (ch.to_int() - '0'.to_int())
    }
    i += 1
  }
  if n >= 1 && n <= level_count {
    Some(n - 1)
  } else {
    None
  }
}

///|
/// 画面遷移の「形」だけを見て history を書き換える。popstate 由来の
/// SyncRoute 遷移では呼ばない（ブラウザがすでに遷移済みのため）。
pub fn sync_url(prev : Screen, next : Screen) -> Unit {
  match (prev, next) {
    (Select, Play(g)) =>
      @history.history().pushState(@jscore.null(), "", url=stage_query(g.level_index))
    (Play(_), Play(g)) =>
      @history.history().replaceState(@jscore.null(), "", url=stage_query(g.level_index))
    (Play(_), Select) => @history.history().back()
    _ => ()
  }
}
