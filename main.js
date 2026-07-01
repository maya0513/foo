// bootstrap（アプリロジックは含めない）。
// vite-plugin-moonbit が `mbt:` を MoonBit の main パッケージに解決し、
// 読み込み時に fn main が走って #app へ描画する。UI ロジックはすべて src/*.mbt 側にある。
import "mbt:maya0513/foo";
