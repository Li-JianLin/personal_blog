<template>
  <div class="projects-view">
    <div class="container">
      <!-- 页面头部 -->
      <PageHeader title="项目展示" description="展示我的技术实践和创作成果"></PageHeader>

      <!-- 项目筛选 -->
      <PageFilter>
        <template #filter-1>
          <el-select
            v-model="selectedStatus"
            placeholder="项目状态"
            clearable
            @change="handleFilterChange"
          >
            <el-option label="全部状态" value="" />
            <el-option label="已完成" value="completed" />
            <el-option label="进行中" value="in-progress" />
            <el-option label="计划中" value="planned" />
          </el-select>
        </template>
        <template #filter-2>
          <el-select
            v-model="selectedTechnology"
            placeholder="技术栈"
            clearable
            @change="handleFilterChange"
          >
            <el-option label="全部技术" value="" />
            <el-option v-for="tech in allTechnologies" :key="tech" :label="tech" :value="tech" />
          </el-select>
        </template>
        <template #filter-3>
          <el-select v-model="sortBy" placeholder="排序方式" @change="handleFilterChange">
            <el-option label="默认排序" value="default" />
            <el-option label="项目名称" value="title" />
            <el-option label="完成状态" value="status" />
          </el-select>
        </template>
      </PageFilter>

      <!-- 项目统计 -->
      <div class="project-stats">
        <div class="stats-grid">
          <div class="stat-item">
            <div class="stat-number">{{ statusStats.completed }}</div>
            <div class="stat-label">已完成项目</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">{{ statusStats['in-progress'] }}</div>
            <div class="stat-label">进行中项目</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">{{ statusStats.planned }}</div>
            <div class="stat-label">计划中项目</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">{{ allTechnologies.length }}</div>
            <div class="stat-label">掌握技术</div>
          </div>
        </div>
      </div>

      <!-- 项目列表 -->
      <div class="projects-container">
        <!-- 加载状态：骨架屏 -->
        <div v-if="loading" class="loading-state">
          <el-skeleton :rows="3" animated />
          <el-skeleton :rows="3" animated />
          <el-skeleton :rows="3" animated />
        </div>

        <div v-else-if="filteredProjects.length === 0" class="empty-state">
          <el-empty description="暂无符合条件的项目" />
        </div>

        <div v-else class="projects-grid">
          <div v-for="project in filteredProjects" :key="project.id" class="project-card">
            <el-card shadow="hover" class="project-card-inner">
              <!-- 项目图片 -->
              <div class="project-image">
                <img :src="project.image" :alt="project.title" />
                <div class="project-overlay">
                  <div class="overlay-content">
                    <el-button type="primary" circle @click="viewDetails(project.id)">
                      <el-icon><View /></el-icon>
                    </el-button>
                  </div>
                </div>
                <div class="project-status">
                  <el-tag :type="getStatusType(project.status)" size="small">
                    {{ getStatusText(project.status) }}
                  </el-tag>
                </div>
              </div>

              <!-- 项目信息 -->
              <div class="project-content">
                <h3 class="project-title">{{ project.title }}</h3>
                <p class="project-description">{{ project.description }}</p>

                <div class="project-technologies">
                  <div class="tech-title">技术栈：</div>
                  <div class="tech-tags">
                    <el-tag
                      v-for="tech in project.technologies"
                      :key="tech"
                      size="small"
                      class="tech-tag"
                      @click="filterByTechnology(tech)"
                    >
                      {{ tech }}
                    </el-tag>
                  </div>
                </div>

                <div class="project-actions">
                  <el-button type="primary" size="small" @click="viewDetails(project.id)">
                    <el-icon><View /></el-icon>
                    查看详情
                  </el-button>
                </div>
              </div>
            </el-card>
          </div>
        </div>
      </div>

      <!-- 技术栈展示 -->
      <div class="technology-showcase">
        <h2 class="section-title">技术栈</h2>
        <TheSkill v-slot="{ skill }">
          <span class="skill-level">{{ skill.level }}%</span>
        </TheSkill>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { View } from '@element-plus/icons-vue'
import PageHeader from '@/components/PageHeader.vue'
import PageFilter from '@/components/PageFilter.vue'
import TheSkill from '@/components/TheSkill.vue'
import supabaseService, { type Project, type TechnologyStat } from '@/services/supabase'
import router from '@/router'

// 响应式数据
const selectedStatus = ref('')
const selectedTechnology = ref('')
const sortBy = ref('default')
const loading = ref(true)

// 项目数据
const projects = ref<Project[]>([])
const allTechnologies = ref<string[]>([])
const statusStats = ref({
  completed: 0,
  'in-progress': 0,
  planned: 0,
})

// 加载项目数据
const loadProjects = async () => {
  try {
    loading.value = true
    const result = await supabaseService.getProjects(
      selectedStatus.value || undefined,
      selectedTechnology.value || undefined,
      sortBy.value,
    )

    projects.value = result.projects
    allTechnologies.value = result.technologies.map((t: TechnologyStat) => t.name)
    statusStats.value = result.statusStats
  } catch (error) {
    console.error('加载项目失败:', error)
  } finally {
    loading.value = false
  }
}

// 处理筛选变化
const handleFilterChange = () => {
  loadProjects()
}

// 根据选择筛选项目（现在由后端处理，这里直接返回）
const filteredProjects = computed(() => {
  return projects.value
})

// 页面挂载时加载数据
onMounted(() => {
  loadProjects()
})

// 方法
// 根据项目状态返回对应的标签类型
const getStatusType = (status: string) => {
  const types: Record<string, string> = {
    completed: 'success',
    'in-progress': 'warning',
    planned: 'info',
  }
  return types[status] || 'info'
}

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    completed: '已完成',
    'in-progress': '进行中',
    planned: '计划中',
  }
  return texts[status] || status
}

const filterByTechnology = (tech: string) => {
  selectedTechnology.value = tech
  loadProjects()
}

const viewDetails = (id: string) => {
  router.push(`/projects/${id}`)
}
</script>

<style scoped>
.projects-view {
  min-height: 100vh;
  background: #f5f7fa;
  padding: 40px 0;
}

.project-stats {
  margin-bottom: 32px;
  padding: 24px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 24px;
}

.stat-item {
  text-align: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 8px;
  transition: transform 0.3s;
}

.stat-item:hover {
  transform: translateY(-2px);
}

.stat-number {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 0.9rem;
  opacity: 0.9;
}

.projects-container {
  margin-bottom: 48px;
}

.loading-state {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 24px;
  margin: 32px 0;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 8px;
}

.projects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 24px;
}

.project-card {
  transition: transform 0.3s;
}

.project-card:hover {
  transform: translateY(-4px);
}

.project-card-inner {
  height: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.project-image {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.project-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.project-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.project-card:hover .project-overlay {
  opacity: 1;
}

.project-card:hover .project-image img {
  transform: scale(1.05);
}

.overlay-content {
  display: flex;
  gap: 16px;
}

.project-status {
  position: absolute;
  top: 12px;
  right: 12px;
}

.project-content {
  padding: 20px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.project-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 12px;
  color: #303133;
}

.project-description {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 16px;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.project-technologies {
  margin-bottom: 16px;
}

.tech-title {
  font-size: 0.9rem;
  color: #909399;
  margin-bottom: 8px;
}

.tech-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tech-tag {
  cursor: pointer;
  transition: transform 0.3s;
  border: none;
  background: #ecf5ff;
  color: #409eff;
}

.tech-tag:hover {
  transform: scale(1.05);
}

.project-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-top: auto;
}

.technology-showcase {
  background: white;
  padding: 32px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 1.8rem;
  margin-bottom: 24px;
  color: #303133;
  text-align: center;
}

.skill-level {
  color: #909399;
  font-size: 0.9rem;
}

/* 响应式设计 */
/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .project-stats,
  .technology-showcase {
    padding: 32px;
  }

  .projects-grid {
    grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
    gap: 32px;
  }

  .stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 32px;
  }
}

/* 大屏幕优化 (1200px - 1919px) */
@media (min-width: 1200px) and (max-width: 1919px) {
  .projects-grid {
    grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
    gap: 28px;
  }

  .stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .projects-grid {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .projects-grid {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 16px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }

  .project-stats,
  .technology-showcase {
    padding: 20px;
  }
}

/* 移动端优化 (≤767px) */
@media (max-width: 767px) {
  .projects-view {
    padding: 20px 0;
  }

  .project-stats {
    margin-bottom: 20px;
    padding: 16px;
  }

  .projects-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .stat-item {
    padding: 16px;
  }

  .stat-number {
    font-size: 1.5rem;
  }

  .project-content {
    padding: 16px;
  }

  .project-actions {
    justify-content: center;
    gap: 6px;
  }

  .technology-showcase {
    padding: 20px;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .project-stats,
  .technology-showcase {
    padding: 12px;
  }

  .project-content {
    padding: 12px;
  }

  .project-title {
    font-size: 1.1rem;
  }

  .project-description {
    font-size: 0.9rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 8px;
  }

  .stat-item {
    padding: 12px;
  }

  .stat-number {
    font-size: 1.3rem;
  }

  .project-actions {
    gap: 4px;
  }

  .tech-tags {
    gap: 4px;
  }
}
</style>
