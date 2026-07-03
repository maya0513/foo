///|
/// クリア状況の永続化。localStorage が使えない環境（プライベートモード等）では
/// 黙って何もしない。副作用はこの層と main.mbt に閉じ、view は純粋に保つ。
extern "js" fn storage_get(key : String) -> String = "(key) => { try { return localStorage.getItem(key) ?? '' } catch { return '' } }"

///|
extern "js" fn storage_set(key : String, value : String) -> Unit = "(key, value) => { try { localStorage.setItem(key, value) } catch {} }"

///|
/// 保存キー。値は '1'（クリア済み）と '0' をステージ順に並べた文字列。
const STORAGE_KEY : String = "flip.cleared.v1"

///|
/// 保存済みのクリア状況を読み込む。未保存・長さ不足は未クリア扱い。
pub fn load_cleared(count : Int) -> Array[Bool] {
  let saved = storage_get(STORAGE_KEY)
  let cleared = Array::make(count, false)
  let mut i = 0
  for ch in saved {
    if i < count && ch == '1' {
      cleared[i] = true
    }
    i += 1
  }
  cleared
}

///|
/// クリア状況を保存する。
pub fn save_cleared(cleared : Array[Bool]) -> Unit {
  let buf = StringBuilder::new()
  for c in cleared {
    buf.write_char(if c { '1' } else { '0' })
  }
  storage_set(STORAGE_KEY, buf.to_string())
}
