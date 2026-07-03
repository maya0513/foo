import { fileURLToPath } from "node:url";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";
import { moonbit } from "vite-plugin-moonbit";

// ページもの（index.html + mbt: を読むだけの main.js）は pages/ に集約している。
// ディレクトリ構成がそのまま URL になる（pages/seron/ → /seron/）。
export default defineConfig({
  root: "pages",
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
        seron: fileURLToPath(new URL("./pages/seron/index.html", import.meta.url)),
      },
    },
  },
});
