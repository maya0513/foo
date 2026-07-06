# foo

MoonBitのwebプロジェクト

## Tech Stack

- MoonBit
- mizchi/luna
- tailwind
- Vite
- vite-plugin-moonbit
- Cloudflare Workers
- Wrangler
- pnpm
- just

## Deploy

- main への push で GitHub Actions（`.github/workflows/deploy.yml`）が実行。CI 内で moon を curl 導入 → `pnpm build` → `wrangler deploy`

# コンテンツ

- flip
- オープンワールド

# 条件

- 各コンテンツは世界観もデザインも完全に独立している
- あるコンテンツを実装するとき、他のコンテンツの実装を読む必要はない。（内容やデザインが寄ってしまうのを避けるため）
- 各コンテンツは世界観から作りこむこと
- 売り出せるレベルのコンテンツを作ること
- 全てのページにレスポンシブデザインを適用すること
- UXを考慮し、必要に応じ無スクロールページにすること
- 足りない実装は自前で用意する、バインディングを書いて利用可能にする、など積極的にしてよい
