///| three.js は動的 import で読み込む。`#module("three")` はクラス
/// コンストラクタを扱えないため、モジュール名前空間そのものを取得して
/// `new m.Scene()` のように第一引数へ回す方式を採る。

///|
extern "js" fn ffi_import_three() -> @js.Promise[@core.Any] =
  #| () => import("three")

///|
/// three モジュールを読み込む。起動時に一度だけ await する。
pub async fn load() -> Three {
  ffi_import_three().wait().cast()
}
