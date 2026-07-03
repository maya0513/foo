// bootstrap（アプリロジックは含めない）。
// vite-plugin-moonbit が `mbt:` を MoonBit の seron パッケージに解決し、
// 読み込み時に fn main が走って #app へ描画する。ゲームロジックはすべて src/seron/**.mbt 側にある。
import "mbt:maya0513/foo/seron";
