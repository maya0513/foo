// bootstrap（アプリロジックは含めない）。
// vite-plugin-moonbit が `mbt:` を MoonBit の flip パッケージに解決し、
// 読み込み時に fn main が走って #app へ描画する。ゲームロジックはすべて src/flip/**.mbt 側にある。
import "mbt:maya0513/foo/flip";
