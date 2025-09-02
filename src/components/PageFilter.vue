<template>
  <!-- 具名插槽 -->
  <div class="filters">
    <div class="filters-row">
      <div class="filter-item">
        <slot name="filter-1"></slot>
      </div>
      <div class="filter-item">
        <slot name="filter-2"></slot>
      </div>
      <div class="filter-item">
        <slot name="filter-3"></slot>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts"></script>
<script lang="ts">
export default {
  name: 'PageFilter',
}
</script>

<style scoped>
.filters {
  margin-bottom: 24px;
  padding: 24px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.filters-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 20px;
  align-items: center;
}

.filter-item {
  width: 100%;
}

/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920) {
  .filters {
    padding: 32px;
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .filters-row {
    grid-template-columns: 1.5fr 1fr 1fr;
    gap: 16px;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .filters {
    padding: 20px;
  }
  .filters-row {
    grid-template-columns: 1fr;
    gap: 16px;
  }
}

/* 超小屏幕优化 (<768px) */
@media (max-width: 767px) {
  .filters {
    margin-bottom: 20px;
    padding: 16px;
  }

  .filters-row {
    grid-template-columns: 1fr;
    gap: 12px;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .filters {
    padding: 12px;
  }
  .filters-row {
    grid-template-columns: 1fr;
    gap: 8px;
  }
}
</style>
