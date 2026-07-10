# world

three.js を MoonBit バインディングで使う低ポリ 3D オープンワールド。URL は `/world/`。

## 構成

- `core/` — 純ロジック。地形・散布・衝突・移動・オービットカメラ。js にも three にも依存せず、すべて *_test.mbt でテストする
- `three/` — three.js バインディング。起動時に動的 import で module namespace を取得し、コンストラクタはインライン JS で `new m.X()` する。ドメイン非依存
- 直下 — 副作用層。main.mbt が起動とループ、bridge.mbt が可変状態の箱と FFI ヘルパ、input.mbt が入力購読、scene.mbt がシーン構築、sync.mbt が毎フレーム反映、hud.mbt が HUD の DOM 構築を担う

core が世界の真実で、three は表示キャッシュ。ワールドは seed 固定で決定的に再生成される。表示と当たり判定は同じ scatter から作るので、見た目と当たりが一致する。

## 規約と落とし穴

- 座標は右手系。カメラが +z を向くとき画面の右はワールド -x になる。yaw は atan2 の dx, dz 規約
- extern "js" の戻り値にタプルは使えない。undefined や NaN に化ける。@core.Any で受けて _get と cast で読む。実例は bridge.mbt の bounding_rect
- .mbt の変更がブラウザに反映されないときは vite を再起動する。変換キャッシュが stale になることがある
- 毎フレームの DOM 更新は luna を通さず style を直接書く
- 移動と視点の操作は独立させる。キーとスティックは移動だけ、ドラッグとホイールは視点だけを動かす。テストで保証している

## 検証

- `just test` で core の純ロジックを確認する
- 実ブラウザ検証はメモリの Browser E2E recipe に従う。dev 用フック globalThis.__world にプレイヤー座標とカメラの向きが、globalThis.__stage に scene と camera が出ているので外から検分できる
