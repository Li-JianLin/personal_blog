<template>
  <div class="tech-grid">
    <div v-for="(skills, category) in skillsByCategory" :key="category" class="tech-category">
      <h3 class="category-title">{{ getCategoryName(category) }}</h3>
      <div class="tech-items">
        <div v-for="skill in skills" :key="skill.name" class="tech-item">
          <div class="skill-info">
            <div class="tech-name">{{ skill.name }}</div>
            <slot :skill="skill"></slot>
            <!-- <span class="skill-level">{{ skill.level }}%</span> -->
          </div>

          <el-progress
            :percentage="skill.level"
            :show-text="false"
            :color="getSkillColor(skill.level)"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default {
  name: 'TheSkill',
}
</script>
<script setup lang="ts">
import { usePortfolioStore } from '@/stores/portfolio'

const store = usePortfolioStore()
const skillsByCategory = store.skillsByCategory

const getCategoryName = (category: string) => {
  const names: Record<string, string> = {
    frontend: '前端技术',
    backend: '后端技术',
    tools: '开发工具',
    others: '其他技能',
  }
  return names[category] || category
}

const getSkillColor = (level: number) => {
  if (level >= 80) return '#67c23a'
  if (level >= 60) return '#e6a23c'
  return '#f56c6c'
}
</script>

<style scoped>
.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 32px;
}

.tech-category {
  background: #f8f9fa;
  padding: 24px;
  border-radius: 8px;
  transition: transform 0.3s;
}

.tech-category:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.category-title {
  font-size: 1.25rem;
  margin-bottom: 20px;
  color: #409eff;
  text-align: center;
}

.tech-items {
  display: flex;
  flex-direction: column;
}

.tech-item {
  padding: 8px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.skill-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.tech-name {
  font-weight: 500;
  font-size: 0.95rem;
  color: #303133;
}

.skill-level {
  color: #909399;
  font-size: 0.9rem;
}

/* 响应式设计 */
/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .tech-grid {
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
    gap: 40px;
  }
}

/* 大屏幕优化 (1200px - 1919px) */
@media (min-width: 1200px) and (max-width: 1919px) {
  .tech-grid {
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .tech-grid {
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 24px;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .tech-grid {
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 20px;
  }
}

/* 移动端优化 (≤767px) */
@media (max-width: 767px) {
  .tech-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  .tech-category {
    padding: 20px;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .tech-category {
    padding: 16px;
  }
  .category-title {
    font-size: 1.1rem;
  }
}
</style>
