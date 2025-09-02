<template>
  <div class="profile-content">
    <div class="profile-text">
      <slot name="intro"></slot>
      <!-- <h2 class="profile-subtitle">{{ personalInfo.title }}</h2> -->
      <div class="profile-description">
        <p v-for="(paragraph, index) in introductionParagraphs" :key="index">
          {{ paragraph }}
        </p>
      </div>
      <slot name="action"></slot>
      <div class="contact-info">
        <div class="contact-item">
          <el-icon><Location /></el-icon>
          <span>{{ personalInfo.location }}</span>
        </div>
        <div class="contact-item">
          <el-icon><Message /></el-icon>
          <span>{{ personalInfo.email }}</span>
        </div>
        <div class="contact-item">
          <el-icon><Phone /></el-icon>
          <span>{{ personalInfo.phone }}</span>
        </div>
      </div>
    </div>
    <div class="profile-avatar">
      <el-avatar :size="200" :src="personalInfo.avatar" />
    </div>
  </div>
</template>

<script lang="ts">
export default {
  name: 'ProfileContent',
}
</script>
<script setup lang="ts">
import { computed } from 'vue'
import { Location, Message, Phone } from '@element-plus/icons-vue'
import { usePortfolioStore } from '@/stores/portfolio'

// 获取数据
const store = usePortfolioStore()
const { personalInfo } = store

// 处理个人介绍段落
// 计算属性
const introductionParagraphs = computed(() => {
  return personalInfo.introduction
    .trim()
    .split('\n')
    .filter((p) => p.trim())
})
</script>

<style scoped>
.profile-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 60px;
}

.profile-text {
  flex: 1;
}

.profile-subtitle {
  font-size: 1.5rem;
  margin-bottom: 24px;
  opacity: 0.9;
}

.profile-description {
  font-size: 1.1rem;
  line-height: 1.8;
  margin-bottom: 32px;
  opacity: 0.9;
}

.profile-description p {
  margin-bottom: 4px;
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1rem;
}

.profile-avatar {
  flex-shrink: 0;
}

/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .profile-subtitle {
    font-size: 1.8rem;
  }
  .profile-description {
    font-size: 1.2rem;
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .profile-content {
    gap: 40px;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .profile-content {
    gap: 32px;
  }

  .profile-subtitle {
    font-size: 1.3rem;
  }
}

/* 移动端优化 (≤767px) */
@media (max-width: 767px) {
  .profile-content {
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 24px;
  }

  .profile-subtitle {
    font-size: 1.1rem;
  }

  .profile-description {
    font-size: 1rem;
  }

  .contact-info {
    align-items: center;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .profile-subtitle {
    font-size: 1rem;
  }
  .profile-description {
    font-size: 0.95rem;
  }
}
</style>
