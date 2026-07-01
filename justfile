default: dev

install:
    pnpm install
    moon install

# MoonBit の型チェック
check:
    moon check --target js

# MoonBit のテスト
test:
    moon test --target js

# Vite 開発サーバー（moon build --watch + HMR）
dev:
    pnpm dev

# 本番ビルド（moon build --release → vite build → dist/）
build:
    pnpm build

# Cloudflare エミュレーター（wrangler dev）で dist を配信
preview: build
    pnpm preview
