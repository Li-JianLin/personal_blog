<template>
  <div class="home-view">
    <!-- 个人介绍区域 -->
    <section class="hero-section">
      <div class="container">
        <ProfileContent>
          <template #intro>
            <h1 class="hero-title">
              你好，我是
              <span class="highlight">{{ personalInfo.name }}</span>
            </h1>
          </template>
          <template #action>
            <div class="hero-actions">
              <el-button type="primary" size="large" @click="scrollToProjects">
                <el-icon><Folder /></el-icon>
                查看项目
              </el-button>
              <el-button size="large" @click="downloadResume">
                <el-icon><Download /></el-icon>
                下载简历
              </el-button>
            </div>
          </template>
        </ProfileContent>
      </div>
    </section>

    <!-- 技能展示 -->
    <section class="skills-section">
      <div class="container">
        <h2 class="section-title">技能专长</h2>
        <TheSkill></TheSkill>
      </div>
    </section>

    <!-- 最新项目 -->
    <section class="projects-section" ref="projectsSection">
      <div class="container">
        <div class="section-header">
          <h2 class="section-title">精选项目</h2>
          <el-button text @click="$router.push('/projects')">
            查看全部 <el-icon><ArrowRight /></el-icon>
          </el-button>
        </div>

        <!-- 项目骨架屏 -->
        <div v-if="loading" class="projects-grid">
          <div v-for="i in 3" :key="`skeleton-project-${i}`" class="project-card">
            <el-card class="project-card-inner">
              <el-skeleton animated>
                <template #template>
                  <div class="project-skeleton">
                    <el-skeleton-item variant="image" style="width: 100%; height: 200px" />
                    <div style="padding: 20px">
                      <el-skeleton-item variant="h3" style="width: 80%" />
                      <el-skeleton-item variant="text" style="margin-top: 16px" />
                      <el-skeleton-item variant="text" style="width: 60%; margin-top: 8px" />
                      <div style="display: flex; gap: 8px; margin-top: 16px">
                        <el-skeleton-item variant="button" style="width: 60px; height: 24px" />
                        <el-skeleton-item variant="button" style="width: 80px; height: 24px" />
                        <el-skeleton-item variant="button" style="width: 70px; height: 24px" />
                      </div>
                    </div>
                  </div>
                </template>
              </el-skeleton>
            </el-card>
          </div>
        </div>

        <!-- 实际项目内容 -->
        <div v-else class="projects-grid">
          <div v-for="project in featuredProjects" :key="project.id" class="project-card">
            <el-card shadow="hover" class="project-card-inner">
              <div class="project-image">
                <img :src="project.image" :alt="project.title" />
                <div class="project-overlay">
                  <el-button circle @click="viewProject(project.id)" title="查看详情">
                    <el-icon><View /></el-icon>
                  </el-button>
                </div>
              </div>
              <div class="project-content">
                <h3 class="project-title">{{ project.title }}</h3>
                <p class="project-description">{{ project.description }}</p>
                <div class="project-technologies">
                  <el-tag
                    v-for="tech in (project.technologies || []).slice(0, 3)"
                    :key="tech"
                    size="small"
                    class="tech-tag"
                  >
                    {{ tech }}
                  </el-tag>
                </div>
              </div>
            </el-card>
          </div>
        </div>
      </div>
    </section>

    <!-- 最新文章 -->
    <section class="articles-section">
      <div class="container">
        <div class="section-header">
          <h2 class="section-title">最新文章</h2>
          <el-button text @click="$router.push('/knowledge')">
            查看全部 <el-icon><ArrowRight /></el-icon>
          </el-button>
        </div>

        <!-- 文章骨架屏 -->
        <div v-if="loading" class="articles-grid">
          <div v-for="i in 3" :key="`skeleton-article-${i}`" class="article-card">
            <el-card class="article-card-inner">
              <el-skeleton animated>
                <template #template>
                  <div class="article-skeleton" style="padding: 20px">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 12px">
                      <el-skeleton-item variant="button" style="width: 60px; height: 24px" />
                      <el-skeleton-item variant="text" style="width: 80px" />
                    </div>
                    <el-skeleton-item variant="h3" style="width: 90%" />
                    <el-skeleton-item variant="text" style="margin-top: 12px" />
                    <el-skeleton-item variant="text" style="width: 70%; margin-top: 8px" />
                    <div
                      style="
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-top: 16px;
                      "
                    >
                      <div style="display: flex; gap: 8px">
                        <el-skeleton-item variant="button" style="width: 50px; height: 20px" />
                        <el-skeleton-item variant="button" style="width: 60px; height: 20px" />
                      </div>
                      <el-skeleton-item variant="text" style="width: 60px" />
                    </div>
                  </div>
                </template>
              </el-skeleton>
            </el-card>
          </div>
        </div>

        <!-- 实际文章内容 -->
        <div v-else class="articles-grid">
          <div v-for="article in latestArticles" :key="article.id" class="article-card">
            <el-card shadow="hover" @click="router.push(`/knowledge/${article.id}`)">
              <div class="article-content">
                <div class="article-meta">
                  <el-tag size="small">{{ article.category }}</el-tag>
                  <span class="article-date">{{ formatDate(article.created_at) }}</span>
                </div>
                <h3 class="article-title">{{ article.title }}</h3>
                <p class="article-summary">{{ article.summary }}</p>
                <div class="article-footer">
                  <div class="article-tags">
                    <el-tag
                      v-for="tag in (article.tags || []).slice(0, 3)"
                      :key="tag"
                      size="small"
                      type="info"
                    >
                      {{ tag }}
                    </el-tag>
                  </div>
                  <span class="read-time">{{ article.reading_time }} 分钟阅读</span>
                </div>
              </div>
            </el-card>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Folder, Download, ArrowRight, View } from '@element-plus/icons-vue'
import TheSkill from '@/components/TheSkill.vue'
import ProfileContent from '@/components/ProfileContent.vue'
import supabaseService, { type Article, type Project } from '@/services/supabase'
import { debounce } from '@/utils/debounce'
import { usePortfolioStore } from '@/stores/portfolio'

const router = useRouter()
const projectsSection = ref<HTMLElement>()

// 响应式数据
const loading = ref(true)
const featuredProjects = ref<Project[]>([])
const latestArticles = ref<Article[]>([])

// 个人信息
const personalInfo = usePortfolioStore().personalInfo

// 加载首页数据
const loadHomeData = async () => {
  try {
    loading.value = true

    // 并行获取项目和文章数据
    const [projectsResult, articlesResult] = await Promise.all([
      supabaseService.getProjects('completed', undefined, 'default'),
      supabaseService.getArticlesOptimized(1, 3, undefined, undefined, 'date'),
    ])

    // 取前3个已完成项目作为精选项目
    featuredProjects.value = projectsResult.projects.slice(0, 3)

    // 取最新的3篇文章
    latestArticles.value = articlesResult.articles.slice(0, 3)
  } catch (error) {
    console.error('加载首页数据失败:', error)
    ElMessage.error('加载数据失败，请刷新页面重试')
  } finally {
    loading.value = false
  }
}

// 方法
const scrollToProjects = () => {
  projectsSection.value?.scrollIntoView({ behavior: 'smooth' })
}

// 简历下载的核心逻辑
const handleDownloadResume = async () => {
  try {
    ElMessage.info('正在下载简历...')
    // 从 Supabase storage 下载简历文件
    const resumeBlob = await supabaseService.downloadResume()

    // 创建下载链接
    const url = window.URL.createObjectURL(resumeBlob)
    const link = document.createElement('a')
    link.href = url
    link.download = '简历_李建林.pdf' // 设置下载文件名
    document.body.appendChild(link)
    link.click()

    // 清理
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)

    ElMessage.success('简历下载成功')
  } catch (error) {
    console.error('下载简历失败:', error)
    ElMessage.error('简历下载失败，请稍后重试')
  }
}

// 应用防抖的简历下载函数
const downloadResume = debounce(handleDownloadResume, 1000) // 1秒防抖

const viewProject = (id: string) => {
  router.push(`/projects/${id}`)
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('zh-CN')
}

// 页面挂载时加载数据
onMounted(() => {
  loadHomeData()
})
</script>

<style scoped>
.home-view {
  overflow-x: hidden;
}

/* 个人介绍区域 */
.hero-section {
  /* 背景图片设置 */
  background: url('/src/assets/hero-bg.jpg') no-repeat fixed;
  background-size: cover;
  background-position: center center;

  /* 基础样式 */
  color: white;
  padding: 80px 0;
  min-height: 500px;
  display: flex;
  align-items: center;

  /* 确保文字可读性 */
  position: relative;
}

/* 为背景添加额外的遮罩层（可选） */
.hero-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1;
}

.hero-section .container {
  position: relative;
  z-index: 2;
}

.hero-title {
  font-size: 3rem;
  font-weight: bold;
  margin-bottom: 16px;
  line-height: 1.2;
}

.highlight {
  color: #409eff;
  font-weight: bold;
}

.hero-actions {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 20px;
}

/* 技能区域 */
.skills-section {
  padding: 80px 0;
  background: white;
}

.section-title {
  text-align: center;
  font-size: 2.5rem;
  margin-bottom: 48px;
  color: #303133;
}

/* 在 section-header 中的标题，移除下边距以确保对齐 */
.section-header .section-title {
  margin-bottom: 0;
  text-align: left;
}

/* 项目区域 */
.projects-section {
  padding: 80px 0;
  background: #f5f7fa;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 48px;
}

.projects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 40px;
  max-width: none; /* 移除最大宽度限制 */
  margin: 0;
}

.project-card {
  transition: transform 0.3s;
  width: 100%;
}

.project-card:hover {
  transform: translateY(-4px);
}

.project-card-inner {
  height: 100%;
  overflow: hidden;
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
  gap: 16px;
  opacity: 0;
  transition: opacity 0.3s;
}

.project-card:hover .project-overlay {
  opacity: 1;
}

.project-card:hover .project-image img {
  transform: scale(1.05);
}

.project-content {
  padding: 20px;
}

.project-title {
  font-size: 1.25rem;
  margin-bottom: 12px;
  color: #303133;
}

.project-description {
  color: #606266;
  line-height: 1.5;
  margin-bottom: 16px;
}

.project-technologies {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tech-tag {
  border: none;
  background: #ecf5ff;
  color: #409eff;
}

/* 文章区域 */
.articles-section {
  padding: 80px 0;
  background: white;
}

.articles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 40px;
  max-width: none; /* 移除最大宽度限制 */
  margin: 0;
}

.article-card {
  cursor: pointer;
  transition: transform 0.3s;
  width: 100%;
}

.article-card:hover {
  transform: translateY(-2px);
}

.article-content {
  padding: 20px;
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.article-date {
  color: #909399;
  font-size: 0.9rem;
}

.article-title {
  font-size: 1.25rem;
  margin-bottom: 12px;
  color: #303133;
}

.article-summary {
  color: #606266;
  line-height: 1.5;
  margin-bottom: 16px;
}

.article-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.article-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.read-time {
  color: #909399;
  font-size: 0.9rem;
  white-space: nowrap;
}

/* 骨架屏样式 */
.project-skeleton,
.article-skeleton {
  width: 100%;
}

.project-skeleton .el-skeleton__image {
  border-radius: 8px;
}

/* 骨架屏动画优化 */
.el-skeleton {
  --el-skeleton-color: #f2f2f2;
  --el-skeleton-to-color: #e6e6e6;
}

/* 确保骨架屏卡片高度一致 */
.project-card .el-skeleton,
.article-card .el-skeleton {
  height: 100%;
}

/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .container {
    padding: 0 48px;
  }

  .hero-section {
    padding: 120px 0;
    min-height: 600px;
    background-attachment: fixed; /* 视差效果 */
  }

  .hero-title {
    font-size: 3.5rem;
  }

  .section-title {
    font-size: 3rem;
  }

  .projects-grid,
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
    gap: 48px;
  }
}

/* 大屏幕优化 (1200px - 1919px) */
@media (min-width: 1200px) and (max-width: 1919px) {
  .container {
    padding: 0 32px;
  }

  .projects-grid,
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(420px, 1fr));
    gap: 36px;
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .container {
    padding: 0 24px;
  }

  .hero-title {
    font-size: 2.5rem;
  }

  .section-title {
    font-size: 2.2rem;
  }

  .projects-grid,
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 32px;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .container {
    padding: 0 20px;
  }

  .hero-section {
    padding: 60px 0;
    min-height: 400px;
    background-attachment: scroll; /* 移动设备取消视差 */
    background-position: center top;
  }

  .hero-title {
    font-size: 2.2rem;
  }

  .section-title {
    font-size: 2rem;
    margin-bottom: 32px;
  }

  .skills-section,
  .projects-section,
  .articles-section {
    padding: 60px 0;
  }

  .projects-grid,
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
  }

  .section-header {
    margin-bottom: 32px;
  }
}

/* 移动端优化 (≤767px) */
@media (max-width: 767px) {
  .container {
    padding: 0 16px;
  }

  .hero-section {
    padding: 55px 0 40px 0;
    min-height: 350px;
    background-attachment: scroll; /* 移动设备必须用scroll */
    background-position: center center;
    /* 增强遮罩以提高文字可读性 */
  }

  .hero-section::before {
    background: rgba(0, 0, 0, 0.4);
  }

  .hero-title {
    font-size: 1.8rem;
  }

  .hero-actions {
    justify-content: center;
    gap: 12px;
  }

  .section-title {
    font-size: 1.8rem;
    margin-bottom: 24px;
  }

  .skills-section,
  .projects-section,
  .articles-section {
    padding: 40px 0;
  }

  .projects-grid,
  .articles-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .section-header {
    gap: 16px;
    text-align: center;
    margin-bottom: 24px;
  }

  .project-content,
  .article-content {
    padding: 16px;
  }

  .article-footer {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .container {
    padding: 0 12px;
  }

  .hero-section {
    padding: 50px 0 32px 0;
    min-height: 300px;
    background-position: center center;
  }

  .hero-section::before {
    background: rgba(0, 0, 0, 0.5); /* 进一步加强遮罩 */
  }

  .hero-title {
    font-size: 1.5rem;
  }

  .hero-actions {
    align-items: center;
    gap: 8px;
  }

  .section-title {
    font-size: 1.5rem;
  }

  .skills-section,
  .projects-section,
  .articles-section {
    padding: 32px 0;
  }

  .project-content,
  .article-content {
    padding: 12px;
  }

  .project-title,
  .article-title {
    font-size: 1.1rem;
  }

  .project-description,
  .article-summary {
    font-size: 0.9rem;
  }
}
</style>
