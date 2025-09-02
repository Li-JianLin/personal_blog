<template>
  <svg viewBox="0 0 24 24" width="1em" height="1em" fill="currentColor" class="code-icon">
    <defs>
      <linearGradient id="codeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color: #3b82f6" />
        <stop offset="50%" style="stop-color: #2563eb" />
        <stop offset="100%" style="stop-color: #1d4ed8" />
      </linearGradient>
    </defs>

    <!-- 背景圆形 -->
    <circle cx="12" cy="12" r="10" fill="url(#codeGradient)" stroke="#1E3A8A" stroke-width="1" />

    <!-- 代码符号 </> -->
    <g
      fill="#FFFFFF"
      font-family="Monaco, 'Cascadia Code', 'Fira Code', Consolas, monospace"
      font-size="8"
      font-weight="600"
    >
      <!-- < 符号 -->
      <text x="7.5" y="14.5" text-anchor="middle">&lt;</text>
      <!-- / 符号 -->
      <text x="12" y="14.5" text-anchor="middle">/</text>
      <!-- > 符号 -->
      <text x="16.5" y="14.5" text-anchor="middle">&gt;</text>
    </g>

    <!-- 添加光泽效果 -->
    <ellipse cx="9.5" cy="8.5" rx="3" ry="2" fill="rgba(255,255,255,0.25)" opacity="0.8" />
  </svg>
</template>

<script setup lang="ts">
// 自定义代码图标组件
</script>

<style scoped>
.code-icon {
  display: inline-block;
  vertical-align: middle;
}
</style>
