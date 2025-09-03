import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue(), vueDevTools()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  build: {
    outDir: 'dist', // 指定构建输出目录
    assetsDir: 'assets', // 指定静态资源（图片、CSS、JS 等）目录
    sourcemap: false, // 关闭 sourcemap生成，source map 文件会暴露源代码，不适合生产环境
    minify: 'terser', // 使用 terser 进行JS代码压缩
    // rollup打包工具配置
    rollupOptions: {
      output: {
        // 代码分割，让常用库单独缓存，减少用户重复下载
        manualChunks: {
          'element-plus': ['element-plus', '@element-plus/icons-vue'],
          router: ['vue-router'],
          store: ['pinia'],
          markdown: ['marked', 'highlight.js'],
        },
      },
    },
  },
  base: '/',
})
