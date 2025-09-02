<template>
  <div class="knowledge-view">
    <div class="container">
      <!-- 页面头部 -->
      <PageHeader title="知识库" description="记录学习过程中的思考与总结" />

      <!-- 搜索和筛选 -->
      <!-- 使用具名插槽 -->
      <PageFilter>
        <template #filter-1>
          <el-input v-model="searchQuery" per="搜索文章..." @input="debouncedSearch">
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </template>
        <template #filter-2>
          <el-select
            v-model="selectedCategory"
            placeholder="选择分类"
            clearable
            @change="handleCategoryChange"
          >
            <el-option label="全部分类" value="" />
            <el-option
              v-for="category in categories"
              :key="category.name"
              :label="category.name"
              :value="category.name"
            />
          </el-select>
        </template>
        <template #filter-3>
          <el-select v-model="sortBy" placeholder="排序方式" @change="handleSortChange">
            <el-option label="最新发布" value="date" />
            <el-option label="阅读时间" value="readTime" />
            <el-option label="标题排序" value="title" />
          </el-select>
        </template>
      </PageFilter>

      <!-- 分类标签 -->
      <div class="category-tags">
        <el-tag
          v-for="category in categories"
          :key="category.name"
          :type="selectedCategory === category.name ? 'primary' : 'info'"
          class="category-tag"
          @click="selectCategory(category.name)"
        >
          {{ category.name }} ({{ category.count }})
        </el-tag>
      </div>

      <!-- 文章列表 -->
      <div class="articles-container">
        <!-- 加载状态：骨架屏 -->
        <div v-if="loading" class="loading-state">
          <el-skeleton :rows="3" animated />
          <el-skeleton :rows="3" animated />
          <el-skeleton :rows="3" animated />
        </div>

        <div v-else-if="filteredArticles.length === 0" class="empty-state">
          <el-empty description="暂无文章" />
        </div>

        <div v-else class="articles-grid">
          <div v-for="article in paginatedArticles" :key="article.id" class="article-card">
            <el-card shadow="hover" @click="viewArticle(article.id)">
              <div class="article-cover" v-if="article.cover_image_url">
                <img :src="article.cover_image_url" :alt="article.title" />
              </div>
              <div class="article-content">
                <div class="article-meta">
                  <el-tag size="small" type="primary">{{ article.category }}</el-tag>
                  <span class="article-date">{{ formatDate(article.created_at) }}</span>
                </div>
                <h2 class="article-title">{{ article.title }}</h2>
                <p class="article-summary">{{ article.summary }}</p>
                <div class="article-tags">
                  <el-tag
                    v-for="tag in article.tags"
                    :key="tag"
                    size="small"
                    type="info"
                    class="tag"
                    @click.stop="searchByTag(tag)"
                  >
                    {{ tag }}
                  </el-tag>
                </div>
                <div class="article-footer">
                  <span class="read-time">
                    <el-icon><Clock /></el-icon>
                    {{ article.reading_time }} 分钟阅读
                  </span>
                  <el-button text type="primary" @click.stop="viewArticle(article.id)">
                    阅读全文 <el-icon><ArrowRight /></el-icon>
                  </el-button>
                </div>
              </div>
            </el-card>
          </div>
        </div>

        <!-- 文章数大于pagsize时，分页显示 -->
        <div class="pagination-container" v-if="totalArticles > pageSize">
          <el-pagination
            v-model:current-page="currentPage"
            :page-size="pageSize"
            :total="totalArticles"
            layout="prev, pager, next, jumper, total"
            @current-change="handlePageChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Clock, ArrowRight } from '@element-plus/icons-vue'
import PageHeader from '@/components/PageHeader.vue'
import PageFilter from '@/components/PageFilter.vue'
import supabaseService, { type ArticleInfo } from '@/services/supabase'
import { debounce } from '@/utils/debounce'

const router = useRouter()
// 响应式数据
const searchQuery = ref('') // 搜索关键词
const selectedCategory = ref('前端开发') // 选中的文章分类，默认为前端开发
const sortBy = ref('date') // 排序方式，默认按日期排序
const currentPage = ref(1) // 当前页码
const pageSize = 6 // 每页显示的文章数量

// 文章和分类数据
// 定义文章的响应式数组，每个元素都是 ArticleInfo 类型
// ([]) 表示初始值为空数组
const articles = ref<ArticleInfo[]>([])
// 定义分类的响应式数组，数组中的每个对象有 name 和 count 属性
// name 是分类名称，count 是该分类下文章的数量
// ([]) 表示初始值为空数组
const categories = ref<Array<{ name: string; count: number }>>([])
const loading = ref(false)
const totalArticles = ref(0) // 总文章数

// 缓存数据，避免重复请求
const articlesCache = new Map() // map对象保存缓存键值对
const categoriesCache = ref<Array<{ name: string; count: number }>>([])

// 从supabase中获取文章的函数
const loadArticlesOptimized = async () => {
  try {
    loading.value = true

    // 生成缓存键（包含排序方式）
    const cacheKey = `opt-${currentPage.value}-${pageSize}-${selectedCategory.value}-${searchQuery.value}-${sortBy.value}`

    // 检查缓存,如有缓存则直接使用
    if (articlesCache.has(cacheKey)) {
      const cached = articlesCache.get(cacheKey)
      articles.value = cached.articles
      totalArticles.value = cached.total
      categories.value = cached.categories || categories.value
      loading.value = false
      return
    }

    // 使用优化的存储过程，一次性获取所有数据
    const result = await supabaseService.getArticlesOptimized(
      currentPage.value,
      pageSize,
      selectedCategory.value || undefined,
      searchQuery.value || undefined,
      sortBy.value,
    )

    articles.value = result.articles || []
    totalArticles.value = result.total || 0

    // 如果返回了分类数据，也更新分类列表
    if (result.categories && result.categories.length > 0) {
      categories.value = result.categories
      categoriesCache.value = result.categories
    }

    // 缓存数据（缓存最近5个请求）
    if (articlesCache.size >= 5) {
      const firstKey = articlesCache.keys().next().value
      articlesCache.delete(firstKey)
    }
    articlesCache.set(cacheKey, {
      articles: articles.value,
      total: totalArticles.value,
      categories: result.categories,
    })
  } catch (error) {
    console.error('加载文章失败', error)
  } finally {
    loading.value = false
  }
}

// 计算属性
const filteredArticles = computed(() => {
  return articles.value
})

// 获取分页文章（由于后端已经分页，这里直接返回）
const paginatedArticles = computed(() => {
  return articles.value
})

// 方法
// 文章分类标签在选中和未选中之间切换
const selectCategory = (category: string) => {
  selectedCategory.value = selectedCategory.value === category ? '' : category
  currentPage.value = 1
  loadArticlesOptimized()
}

const handleCategoryChange = () => {
  currentPage.value = 1
  loadArticlesOptimized()
}

const handleSortChange = () => {
  // 清除缓存，因为排序方式改变了
  articlesCache.clear()
  // 重置到第一页
  currentPage.value = 1
  // 重新加载文章
  loadArticlesOptimized()
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  loadArticlesOptimized()
}

const viewArticle = (id: string) => {
  router.push(`/knowledge/${id}`)
}

// 防抖搜索
const debouncedSearch = debounce(() => {
  currentPage.value = 1
  loadArticlesOptimized()
}, 500)

const searchByTag = (tag: string) => {
  searchQuery.value = tag
  selectedCategory.value = ''
  currentPage.value = 1
  loadArticlesOptimized()
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

onMounted(async () => {
  // 并行加载分类和文章数据
  await loadArticlesOptimized()
})
</script>

<style scoped>
.knowledge-view {
  min-height: 100vh;
  background: #f5f7fa;
  padding: 40px 0;
}

.category-tags {
  margin-bottom: 32px;
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: center;
}

.category-tag {
  cursor: pointer;
  transition: all 0.3s;
}

.category-tag:hover {
  transform: translateY(-1px);
}

.articles-container {
  background: white;
  border-radius: 8px;
  padding: 32px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.empty-state {
  text-align: center;
  padding: 60px 0;
}

.loading-state {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.articles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.article-card {
  cursor: pointer;
  transition: transform 0.3s;
  height: 100%;
}

.article-card:hover {
  transform: translateY(-4px);
}

.article-card .el-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.article-cover {
  height: 180px;
  overflow: hidden;
  border-radius: 4px 4px 0 0;
  margin: -20px -20px 16px -20px;
}

.article-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.article-card:hover .article-cover img {
  transform: scale(1.05);
}

.article-content {
  padding: 20px;
  flex: 1;
  display: flex;
  flex-direction: column;
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
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.article-summary {
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

.article-tags {
  margin-bottom: 16px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  cursor: pointer;
  transition: all 0.3s;
}

.tag:hover {
  transform: scale(1.05);
}

.article-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
  margin-top: auto;
}

.read-time {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #909399;
  font-size: 0.9rem;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}

/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
    gap: 32px;
  }

  .articles-container {
    padding: 48px;
  }
}

/* 大屏幕优化 (1200px - 1919px) */
@media (min-width: 1200px) and (max-width: 1919px) {
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
    gap: 28px;
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 20px;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .articles-grid {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 16px;
  }

  .articles-container {
    padding: 24px;
  }
}

/* 移动端优化 (≤767px) */
@media (max-width: 767px) {
  .knowledge-view {
    padding: 20px 0;
  }

  .category-tags {
    margin-bottom: 24px;
    gap: 8px;
  }

  .articles-grid {
    grid-template-columns: 1fr;
    gap: 16px;
    margin-bottom: 24px;
  }

  .articles-container {
    padding: 16px;
  }

  .article-content {
    padding: 16px;
  }

  .article-cover {
    margin: -16px -16px 12px -16px;
    height: 160px;
  }

  .article-footer {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }

  .pagination-container {
    margin-top: 24px;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .articles-container {
    padding: 12px;
  }

  .article-content {
    padding: 12px;
  }

  .article-cover {
    margin: -12px -12px 8px -12px;
    height: 140px;
  }

  .article-title {
    font-size: 1.1rem;
  }

  .article-summary {
    font-size: 0.9rem;
  }

  .category-tags {
    gap: 6px;
  }

  .article-tags {
    gap: 6px;
  }
}
</style>
