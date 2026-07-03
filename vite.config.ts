import { fileURLToPath } from "node:url";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";
import { moonbit } from "vite-plugin-moonbit";

// ページもの（index.html + mbt: を読むだけの main.js）は pages/ に集約している。
// ディレクトリ構成がそのまま URL になる（pages/seron/ → /seron/）。
export default defineConfig({
  root: "pages",
  server: {
    port: 5173,
    strictPort: true,
  },
  preview: {
    port: 5173,
    strictPort: true,
  },
  plugins: [
    tailwindcss(),
    moonbit({ target: "js", mode: "release", root: fileURLToPath(new URL(".", import.meta.url)) }),
  ],
  build: {
    outDir: "../dist",
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: fileURLToPath(new URL("./pages/index.html", import.meta.url)),
        flip: fileURLToPath(new URL("./pages/flip/index.html", import.meta.url)),
      },
    },
  },
});
