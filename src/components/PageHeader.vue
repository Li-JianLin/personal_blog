<template>
  <!-- 页面头部 -->
  <div class="page-header">
    <h1 class="page-title">{{ title }}</h1>
    <p class="page-description">{{ description }}</p>
  </div>
</template>

<script lang="ts">
export default {
  name: 'PageHeader',
}
</script>

<script setup lang="ts">
import { defineProps } from 'vue'
defineProps(['title', 'description'])
</script>

<style scoped>
.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-title {
  font-size: 2.5rem;
  color: #303133;
  margin-bottom: 16px;
}

.page-description {
  font-size: 1.1rem;
  color: #606266;
}

/* 响应式设计 */
/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .page-title {
    font-size: 3rem;
  }

  .page-description {
    font-size: 1.2rem;
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .page-title {
    font-size: 2.2rem;
  }

  .page-description {
    font-size: 1.1rem;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .page-title {
    font-size: 2rem;
  }

  .page-description {
    font-size: 1rem;
  }
}

/* 移动端优化 (<768px) */
@media (max-width: 767px) {
  .page-header {
    margin-top: 24px;
    margin-bottom: 24px;
  }
  .page-title {
    font-size: 1.8rem;
  }

  .page-description {
    font-size: 0.9rem;
  }
}

/* 超小屏幕优化 (<=480px) */
@media (max-width: 480px) {
  .page-title {
    font-size: 1.5rem;
  }

  .page-description {
    font-size: 0.8rem;
  }
}
</style>
