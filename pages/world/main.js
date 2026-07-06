// bootstrap（アプリロジックは含めない）。
// vite-plugin-moonbit が `mbt:` を MoonBit の world パッケージに解決し、
// 読み込み時に fn main が走ってオープンワールドを起動する。
// three.js は MoonBit 側の動的 import で読み込む。ロジックはすべて src/world/**.mbt にある。
import "mbt:maya0513/foo/world";
