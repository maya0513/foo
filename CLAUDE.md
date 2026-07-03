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
