<template>
  <div class="article-detail-view">
    <div class="container">
      <!-- 加载状态：显示骨架屏 -->
      <div v-if="loading" class="loading-container">
        <div class="article-header">
          <el-skeleton :rows="1" animated style="margin-bottom: 20px" />
          <el-skeleton :rows="3" animated />
        </div>
        <div class="article-content">
          <div class="content-wrapper">
            <el-skeleton :rows="15" animated />
          </div>
        </div>
      </div>

      <!-- 文章不存在的错误提示 -->
      <div v-else-if="!loading && !article" class="not-found">
        <el-result icon="warning" title="文章不存在" sub-title="您访问的文章可能已被删除或不存在">
          <template #extra>
            <el-button type="primary" @click="$router.push('/knowledge')"> 返回知识库 </el-button>
          </template>
        </el-result>
      </div>

      <!-- 文章内容 -->
      <div v-else class="article-container">
        <!-- 文章头部 -->
        <div class="article-header">
          <nav class="breadcrumb">
            <el-breadcrumb separator="/">
              <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
              <el-breadcrumb-item :to="{ path: '/knowledge' }">知识库</el-breadcrumb-item>
              <el-breadcrumb-item>{{ article?.title || '加载中...' }}</el-breadcrumb-item>
            </el-breadcrumb>
          </nav>

          <h1 class="article-title">{{ article?.title || '加载中...' }}</h1>

          <!-- 文章元数据 -->
          <div class="article-meta">
            <div class="meta-left">
              <el-tag v-if="article?.category" type="primary">{{ article.category }}</el-tag>
              <span v-if="article?.created_at" class="publish-date">{{
                formatDate(article.created_at)
              }}</span>
              <span v-if="article?.reading_time" class="read-time">
                <el-icon><Clock /></el-icon>
                {{ article.reading_time }} 分钟阅读
              </span>
            </div>
            <div class="meta-right">
              <el-button size="small" @click="shareArticle">
                <el-icon><Share /></el-icon>
                分享
              </el-button>
            </div>
          </div>

          <div class="article-tags">
            <el-tag v-for="tag in article?.tags || []" :key="tag" size="small" type="info">
              {{ tag }}
            </el-tag>
          </div>
        </div>

        <!-- 文章内容 -->
        <div class="article-content">
          <!-- 文章导航目录 - 桌面端 -->
          <div
            v-show="showToc && !isMobileOrTablet"
            class="article-nav desktop-toc"
            @mouseleave="debouncedHideToc"
          >
            <div class="nav-header">
              <h3>目录</h3>
              <button class="toc-toggle" @click="showToc = false" title="隐藏目录">✕</button>
            </div>
            <div class="nav-list">
              <div
                v-for="heading in headings"
                :key="heading.id"
                :class="[
                  'nav-item',
                  `level-${heading.level}`,
                  { active: currentHeading === heading.id },
                ]"
                @click="scrollToHeading(heading.id)"
              >
                {{ heading.text }}
              </div>
            </div>
          </div>

          <!-- 目录切换按钮（桌面端当目录隐藏时显示） -->
          <button
            v-show="!showToc && !isMobileOrTablet"
            class="toc-show-btn desktop-toc-btn"
            title="显示目录"
            @mouseenter="throttledShowToc"
          >
            📋 目录
          </button>

          <!-- 移动端/平板端目录按钮 -->
          <button
            v-show="isMobileOrTablet && headings.length > 0"
            class="mobile-toc-btn"
            @click="showMobileToc = true"
            title="显示目录"
          >
            📋 目录
          </button>

          <!-- 文章主内容 -->
          <div class="content-wrapper">
            <MarkdownRenderer
              v-if="article"
              :content="article.content || ''"
              :images="articleImages"
            />
          </div>
        </div>

        <!-- 相关文章推荐 -->
        <div class="related-articles">
          <h2 class="section-title">相关文章</h2>
          <div class="related-grid">
            <div
              v-for="relatedArticle in relatedArticles"
              :key="relatedArticle.id"
              class="related-card"
            >
              <el-card shadow="hover" @click="viewArticle(relatedArticle.id || '')">
                <div class="related-content">
                  <h3 class="related-title">{{ relatedArticle.title }}</h3>
                  <p class="related-summary">{{ relatedArticle.summary }}</p>
                  <div class="related-meta">
                    <el-tag size="small">{{ relatedArticle.category }}</el-tag>
                    <span class="related-date">{{
                      formatDate(relatedArticle.created_at || '')
                    }}</span>
                  </div>
                </div>
              </el-card>
            </div>
          </div>
        </div>

        <!-- 返回顶部和导航按钮 -->
        <div class="action-buttons">
          <el-button
            type="primary"
            circle
            @click="scrollToTop"
            v-show="showBackToTop"
            title="返回顶部"
          >
            <el-icon><Top /></el-icon>
          </el-button>
          <el-button circle @click="$router.back()" title="返回上一页">
            <el-icon><Back /></el-icon>
          </el-button>
        </div>
      </div>
    </div>

    <!-- 移动端/平板端目录弹窗 -->
    <el-drawer
      v-model="showMobileToc"
      :direction="isMobile ? 'btt' : 'rtl'"
      :size="isMobile ? '70%' : '350px'"
      title="文章目录"
      body-class="mobile-toc-drawer"
    >
      <div class="mobile-nav-list">
        <div
          v-for="heading in headings"
          :key="heading.id"
          :class="[
            'mobile-nav-item',
            `level-${heading.level}`,
            { active: currentHeading === heading.id },
          ]"
          @click="scrollToHeadingMobile(heading.id)"
        >
          {{ heading.text }}
        </div>
        <div v-if="headings.length === 0" class="no-headings">暂无目录</div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Clock, Share, Top, Back } from '@element-plus/icons-vue'
import MarkdownRenderer from '@/components/MarkdownRenderer.vue'
import supabaseService, { type Article, type ArticleImage } from '@/services/supabase'
import { throttle, debounce } from '@/utils/debounce'

const route = useRoute()
const router = useRouter()

// 响应式数据
const showBackToTop = ref(false) // 返回顶部按钮显示/隐藏状态
const showToc = ref(false) // 桌面端目录显示/隐藏状态
const showMobileToc = ref(false) // 移动端目录弹窗显示/隐藏状态
const currentHeading = ref('') // 当前阅读位置的标题ID
const article = ref<Article | null>(null)
const articleImages = ref<ArticleImage[]>([])
const relatedArticles = ref<Partial<Article>[]>([])

const loading = ref(true)

// 响应式检测
const isMobileOrTablet = computed(() => {
  if (typeof window === 'undefined') return false
  // 屏幕宽度小于等于991px，视为移动端或平板端
  return window.innerWidth <= 991 // 包含平板和移动端
})

const isMobile = computed(() => {
  if (typeof window === 'undefined') return false
  // 屏幕宽度小于等于767px，视为移动端
  return window.innerWidth <= 767 // 仅移动端
})

// 目录显示/隐藏的优化处理
let hideTimeoutId: ReturnType<typeof setTimeout> | null = null

// 节流的目录显示函数
const throttledShowToc = throttle(() => {
  // 清除隐藏定时器
  if (hideTimeoutId) {
    clearTimeout(hideTimeoutId)
    hideTimeoutId = null
  }
  showToc.value = true
}, 100) // 100ms 节流，显示要快一些

// 防抖的目录隐藏函数
const debouncedHideToc = debounce(() => {
  hideTimeoutId = setTimeout(() => {
    showToc.value = false
  }, 300) // 300ms 延迟隐藏，给用户时间移动鼠标
}, 150) // 150ms 防抖

// 计算属性：提取标题作为目录
const headings = computed(() => {
  if (!article.value?.content) return []

  const content = article.value.content
  const headingRegex = /^(#{1,6})\s+(.*)$/gm
  const headings = []
  let match
  let index = 0

  while ((match = headingRegex.exec(content)) !== null) {
    const headingText = match[2].trim()
    // 生成更稳定的 ID，基于文本内容
    const headingId = `heading-${index}`
    headings.push({
      id: headingId,
      level: match[1].length,
      text: headingText,
    })
    index++
  }

  return headings
})

// 方法
const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

const shareArticle = () => {
  // 如果浏览器支持 Web Share API，则生成分享链接
  if (navigator.share) {
    navigator.share({
      title: article.value?.title,
      text: article.value?.summary,
      url: window.location.href,
    })
  } else {
    // 复制链接到剪贴板
    navigator.clipboard.writeText(window.location.href)
    ElMessage.success('链接已复制到剪贴板')
  }
}

const viewArticle = (id: string) => {
  router.push(`/knowledge/${id}`)
}

const scrollToHeading = (headingId: string) => {
  // 查找目标标题元素
  const targetElement = document.getElementById(headingId)
  if (!targetElement) {
    return
  }

  // 计算目标位置，留出一些顶部空间避免被遮挡
  let offsetPixel = 100 // 默认桌面端顶部偏移
  if (isMobileOrTablet.value) {
    // 移动端滚动时顶部偏移更大
    offsetPixel = 130
  }
  const elementTop = targetElement.offsetTop
  const offsetPosition = elementTop - offsetPixel

  // 平滑滚动到计算出的位置
  window.scrollTo({
    top: offsetPosition,
    behavior: 'instant', // 立即滚动，避免滚动不流畅
  })
}

const scrollToHeadingMobile = (headingId: string) => {
  // 移动端滚动到指定标题并关闭目录弹窗
  scrollToHeading(headingId)
  showMobileToc.value = false
}

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// 处理滚动事件，当滚动超过300px时显示返回顶部按钮，并跟踪当前阅读位置
const handleScroll = throttle(() => {
  // 显示/隐藏返回顶部按钮
  showBackToTop.value = window.scrollY > 300
  // 跟踪当前阅读位置的标题
  updateCurrentHeading()
}, 200) // 200ms 节流，平衡性能和响应性

// 更新当前阅读位置的标题ID
const updateCurrentHeading = () => {
  if (headings.value.length === 0) return

  const scrollTop = window.scrollY
  const offset = 100 // 偏移量，当标题距离顶部100px时认为是当前标题

  // 找到所有页面中的标题元素
  const headingElements = headings.value
    .map((heading) => ({
      id: heading.id,
      element: document.getElementById(heading.id),
      level: heading.level,
    }))
    .filter((item) => item.element) // 过滤掉找不到的元素

  if (headingElements.length === 0) return

  // 找到当前应该高亮的标题
  let activeHeading = ''
  for (let i = 0; i < headingElements.length; i++) {
    const current = headingElements[i]
    const next = headingElements[i + 1]
    const currentTop = current.element!.offsetTop

    // 当卷去的标题进入视口时
    if (scrollTop + offset >= currentTop) {
      // 且没有下一个标题，或者还没有滚动到下一个标题
      if (!next || scrollTop + offset < next.element!.offsetTop) {
        activeHeading = current.id
      }
    }
  }

  // 如果没有找到任何标题在视口中，并且滚动位置在第一个标题之前
  if (!activeHeading && headingElements.length > 0) {
    const firstHeading = headingElements[0]
    if (scrollTop + offset < firstHeading.element!.offsetTop) {
      activeHeading = '' // 在第一个标题之前，不高亮任何标题
    }
  }

  // 更新当前标题
  if (currentHeading.value !== activeHeading) {
    currentHeading.value = activeHeading
    if (import.meta.env.DEV && activeHeading) {
      console.log(`Current heading: ${activeHeading}`)
    }
  }
}

// 加载文章数据
const loadArticle = async () => {
  try {
    loading.value = true
    const art_id = route.params.id as string

    // 使用优化版本的存储过程获取文章详情
    const result = await supabaseService.getArticleDetailOptimized(art_id)
    article.value = result.article
    articleImages.value = result.images
    relatedArticles.value = result.related_articles

    // 增加浏览量
    await supabaseService.incrementViewCount(result.article.id)
  } catch (error) {
    console.error('加载文章失败:', error)
    ElMessage.error('文章加载失败')
  } finally {
    loading.value = false
  }
}

// 页面挂载完毕后，加载文章数据和添加滚动事件监听
onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  window.addEventListener('resize', handleResize)
  loadArticle()
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
  window.removeEventListener('resize', handleResize)
  // 清理目录相关的定时器
  if (hideTimeoutId) {
    clearTimeout(hideTimeoutId)
    hideTimeoutId = null
  }
})

// 处理窗口大小变化
const handleResize = () => {
  // 当从移动端切换到桌面端时，关闭移动端目录弹窗
  if (!isMobileOrTablet.value && showMobileToc.value) {
    showMobileToc.value = false
  }
  // 当从桌面端切换到移动端时，关闭桌面端目录
  if (isMobileOrTablet.value && showToc.value) {
    showToc.value = false
  }
}
</script>

<style scoped>
/* 加载状态样式 */
.loading-container {
  display: grid;
  grid-template-columns: 1fr;
  gap: 32px;
  max-width: 100%;
  overflow-x: hidden;
}

.loading-container .article-header {
  background: white;
  padding: 32px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.loading-container .article-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.loading-container .content-wrapper {
  padding: 32px;
  border-radius: 8px;
}

.article-detail-view {
  min-height: 100vh;
  background: #f5f7fa;
  padding: 40px 0;
  overflow-x: hidden; /* 防止横向滚动 */
}

.not-found {
  padding: 60px 0;
}

.article-container {
  display: grid;
  grid-template-columns: 1fr;
  gap: 32px;
  max-width: 100%; /* 确保不超出视口 */
  overflow-x: hidden; /* 防止横向滚动 */
}

/* 文章头部 */
.article-header {
  background: white;
  padding: 32px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.breadcrumb {
  margin-bottom: 24px;
}

.article-title {
  font-size: 2.5rem;
  font-weight: bold;
  color: #303133;
  margin-bottom: 20px;
  line-height: 1.3;
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #ebeef5;
}

.meta-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.publish-date,
.read-time {
  color: #909399;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 4px;
}

.article-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

/* 文章内容 */
.article-content {
  display: block; /* 改为块布局，因为目录现在是固定定位 */
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  max-width: 100%; /* 确保不超出容器 */
  overflow-x: hidden; /* 防止横向滚动 */
  transition: margin-left 0.3s ease; /* 添加过渡效果 */
}

.content-wrapper {
  padding: 32px;
  border-radius: 8px;
  min-width: 0; /* 允许 flexbox 子元素收缩 */
  overflow-x: hidden; /* 防止内容溢出 */
  width: 100%;
}

/* 显示目录按钮 */
.toc-show-btn {
  position: fixed;
  top: 50%;
  left: 20px;
  transform: translateY(-50%);
  background: #409eff;
  color: white;
  border: none;
  padding: 12px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  transition: all 0.3s;
}

.toc-show-btn:hover {
  background: #337ecc;
  transform: translateY(-50%) scale(1.05);
}

/* 移动端和平板端目录按钮 */
.mobile-toc-btn {
  position: fixed;
  top: 120px;
  right: 20px;
  background: #409eff;
  color: white;
  border: none;
  padding: 12px 16px;
  border-radius: 25px;
  cursor: pointer;
  font-size: 14px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  transition: all 0.3s;
  white-space: nowrap;
}

.mobile-toc-btn:hover {
  background: #337ecc;
  transform: scale(1.05);
}

/* 移动端目录弹窗样式 */
/* 直接覆盖 Element Plus Drawer 的默认样式 */
:deep(.el-drawer__body) {
  padding: 0;
}

:deep(.el-drawer__header) {
  padding: 20px 20px 10px 20px;
  margin-bottom: 0;
  border-bottom: 1px solid #ebeef5;
}

:deep(.el-drawer__title) {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.mobile-toc-drawer {
  z-index: 2000;
}

.mobile-nav-list {
  padding: 10px 0;
}

.mobile-nav-item {
  padding: 12px 20px;
  cursor: pointer;
  border-radius: 8px;
  transition: all 0.3s;
  font-size: 15px;
  color: #606266;
  margin: 4px 20px;
  border-left: 3px solid transparent;
}

.mobile-nav-item:hover {
  background: #f5f7fa;
  color: #409eff;
  border-left-color: #409eff;
}

.mobile-nav-item.level-1 {
  font-weight: 600;
  font-size: 16px;
  color: #303133;
  margin-left: 20px;
}

.mobile-nav-item.level-2 {
  margin-left: 40px;
  font-size: 15px;
}

.mobile-nav-item.level-3 {
  margin-left: 60px;
  font-size: 14px;
  color: #909399;
}

.mobile-nav-item.level-4 {
  margin-left: 80px;
  font-size: 13px;
  color: #c0c4cc;
}

.mobile-nav-item.active {
  background: #409eff;
  color: white;
  border-left-color: white;
  font-weight: 600;
}

.no-headings {
  text-align: center;
  color: #909399;
  padding: 40px 20px;
  font-size: 14px;
}

/* 文章导航目录 */
.article-nav {
  width: 250px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 8px;
  height: fit-content;
  max-height: calc(100vh - 160px); /* 限制最大高度 */
  position: fixed; /* 改为固定定位 */
  top: 80px; /* 距离顶部的距离，避免被头部遮挡 */
  left: 20px; /* 固定在左侧 */
  z-index: 1000; /* 确保在其他内容之上 */
  overflow-y: auto; /* 目录区域独立滚动 */
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15); /* 增强阴影，突出显示 */
}

.nav-header {
  padding: 20px 20px 16px 20px;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-header h3 {
  margin: 0;
  color: #303133;
  font-size: 1.1rem;
}

.toc-toggle {
  background: none;
  border: none;
  color: #909399;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.3s;
}

.toc-toggle:hover {
  background: #f5f7fa;
  color: #409eff;
}

.nav-list {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: calc(100vh - 300px); /* 为目录列表设置最大高度 */
  overflow-y: auto; /* 目录列表独立滚动 */
}

/* 自定义目录的滚动条样式  */
.nav-list::-webkit-scrollbar {
  width: 6px;
}

.nav-list::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.nav-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.nav-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

.nav-item {
  padding: 4px 12px;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.3s;
  font-size: 0.9rem;
  color: #606266;
}

.nav-item:hover {
  background: #f5f7fa;
  color: #409eff;
}

.nav-item.level-1 {
  font-weight: 600;
  padding-left: 8px;
}

.nav-item.level-2 {
  padding-left: 16px;
}

.nav-item.level-3 {
  padding-left: 24px;
}

.nav-item.active {
  background: #409eff;
  color: white;
  font-weight: 600;
}

.nav-item.active:hover {
  background: #337ecc;
  color: white;
}

/* 相关文章 */
.related-articles {
  background: white;
  padding: 32px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 1.5rem;
  margin-bottom: 24px;
  color: #303133;
}

.related-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.related-card {
  cursor: pointer;
  transition: transform 0.3s;
}

.related-card:hover {
  transform: translateY(-2px);
}

.related-content {
  padding: 16px;
}

.related-title {
  font-size: 1.1rem;
  margin-bottom: 8px;
  color: #303133;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.related-summary {
  color: #606266;
  font-size: 0.9rem;
  margin-bottom: 12px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.related-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.related-date {
  color: #909399;
  font-size: 0.8rem;
}

/* 操作按钮 */
.action-buttons {
  position: fixed;
  right: 24px;
  bottom: 24px;
  display: flex;
  flex-direction: column;
  align-items: baseline;
  gap: 12px;
  z-index: 1000;
}

/* 响应式设计 */
/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .article-title {
    font-size: 3rem;
  }

  .related-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 32px;
  }

  .article-main {
    font-size: 1.1rem;
    line-height: 2;
  }
}

/* 大屏幕优化 (1200px - 1919px) */
@media (min-width: 1200px) and (max-width: 1919px) {
  .related-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .article-title {
    font-size: 2.2rem;
  }

  .article-nav {
    width: 220px; /* 稍微减小目录宽度 */
  }

  .related-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }
}

/* 平板优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .article-title {
    font-size: 2rem;
  }

  /* 隐藏桌面端目录相关元素 */
  .desktop-toc,
  .desktop-toc-btn {
    display: none !important;
  }

  /* 显示移动端目录按钮 */
  .mobile-toc-btn {
    display: block;
  }

  .content-wrapper {
    width: 100%;
  }

  .related-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }

  .action-buttons {
    right: 20px;
    bottom: 20px;
  }
}

/* 移动端优化 (≤767px) */
@media (max-width: 767px) {
  .article-container {
    gap: 20px; /* 减少网格间距 */
  }

  .article-detail-view {
    padding: 20px 10px; /* 减少左右 padding */
    overflow-x: hidden;
  }

  /* 隐藏桌面端目录相关元素 */
  .desktop-toc,
  .desktop-toc-btn {
    display: none !important;
  }

  /* 移动端目录按钮样式调整 */
  .mobile-toc-btn {
    top: 80px;
    right: 15px;
    padding: 10px 14px;
    font-size: 13px;
    border-radius: 20px;
  }

  /* 移动端目录项样式优化 */
  .mobile-nav-item {
    padding: 7px 16px;
    font-size: 14px;
    margin: 2px 16px;
  }

  .mobile-nav-item.level-1 {
    font-size: 15px;
    margin-left: 16px;
  }

  .mobile-nav-item.level-2 {
    margin-left: 32px;
    font-size: 14px;
  }

  .mobile-nav-item.level-3 {
    margin-left: 48px;
    font-size: 13px;
  }

  .mobile-nav-item.level-4 {
    margin-left: 64px;
    font-size: 12px;
  }

  .article-header {
    padding: 20px 16px; /* 减少 padding */
  }

  .article-title {
    font-size: 1.8rem;
    line-height: 1.3;
    word-wrap: break-word; /* 确保长标题换行 */
  }

  .article-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .meta-left {
    flex-wrap: wrap;
    gap: 8px;
  }

  .meta-right {
    width: 100%;
    display: flex;
    justify-content: flex-start;
  }

  .article-content {
    margin-left: 0; /* 移动端取消左边距 */
    overflow-x: hidden;
  }

  .content-wrapper {
    width: 100%;
    padding: 16px; /* 减少 padding */
    min-width: 0;
    overflow-x: hidden;
    max-height: none; /* 移动端取消高度限制 */
    overflow-y: visible; /* 移动端使用页面滚动 */
  }

  .related-articles {
    padding: 16px; /* 减少 padding */
  }

  .related-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .action-buttons {
    right: 16px;
    bottom: 16px;
    flex-direction: column;
    gap: 8px;
  }

  .breadcrumb {
    margin-bottom: 16px;
  }

  .article-tags {
    flex-wrap: wrap;
    gap: 6px;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .article-detail-view {
    padding: 15px 5px; /* 进一步减少 padding */
  }

  .article-header {
    padding: 16px 12px; /* 减少 padding */
  }

  .article-title {
    font-size: 1.5rem;
    word-wrap: break-word;
  }

  .content-wrapper {
    padding: 12px; /* 减少 padding */
    font-size: 0.95rem;
    overflow-x: hidden;
  }

  .related-articles {
    padding: 12px; /* 减少 padding */
  }

  .related-grid {
    gap: 8px;
  }

  .action-buttons {
    right: 12px;
    bottom: 12px;
  }

  .meta-left {
    font-size: 0.9rem;
  }

  .article-tags .el-tag {
    font-size: 0.8rem;
  }
}
</style>
