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
- （今後制作予定）

# 条件

- 各ゲームは完全に独立している
- 各ゲームは世界観から作りこむこと
- 売り出せるレベルのゲームを作ること
- 全てのページにレスポンシブデザインを適用すること
- UXを考慮し、必要に応じ無スクロールページにすること
