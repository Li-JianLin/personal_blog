import { createClient, SupabaseClient } from '@supabase/supabase-js'

// 文章信息接口（用于卡片展示）
interface ArticleInfo {
  id: string
  title: string
  slug: string
  summary?: string
  category?: string // 文章分类
  tags?: string[] // 文章标签
  cover_image_url?: string // 封面图片 URL
  view_count: number
  reading_time: number
  created_at: string
  updated_at: string
}

// 文章接口（包括内容）
interface Article {
  id: string
  title: string
  slug: string
  summary?: string
  content?: string //存储markdown内容
  cover_image_url?: string // 封面图片 URL
  category?: string // 文章分类
  tags?: string[] // 文章标签
  author_id: string // 作者 ID
  status: string
  view_count: number
  word_count: number
  reading_time: number
  created_at: string
  updated_at: string
}

interface ArticleImage {
  id: string
  article_id: string
  image_url: string
  alt_text?: string
  caption?: string
  width?: number
  height?: number
  file_size?: number
  position_in_content?: number // 在文章内容中的位置
  is_cover: boolean
  created_at: string
}

// 项目数据接口
interface Project {
  id: string
  title: string
  description: string
  image?: string
  technologies: string[]
  status: 'completed' | 'in-progress' | 'planned'
  category?: string
  created_at: string
  updated_at: string
  view_count: number
  reading_time: number
}

// 技术栈统计接口
interface TechnologyStat {
  name: string
  count: number
}

class SupabaseService {
  private supabase: SupabaseClient

  constructor() {
    const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
    const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Supabase URL and Key must be provided')
    }

    this.supabase = createClient(supabaseUrl, supabaseKey)
  }

  // 获取文章列表（使用存储过程优化版本）
  async getArticlesOptimized(
    page = 1,
    pageSize = 6,
    category?: string,
    searchQuery?: string,
    sortBy = 'date',
  ) {
    const { data, error } = await this.supabase.rpc('get_articles_with_pagination', {
      p_page: page,
      p_page_size: pageSize,
      p_category: category || null,
      p_search_query: searchQuery || null,
      p_sort_by: sortBy,
    })

    if (error) {
      console.error('获取文章列表失败:', error)
      throw error
    }

    return {
      articles: data?.articles || [],
      total: data?.total_count || 0,
      categories: data?.categories || [],
    }
  }

  // 获取单篇文章详情（使用存储过程优化版本）
  async getArticleDetailOptimized(id: string) {
    const { data, error } = await this.supabase.rpc('get_article_detail', {
      p_article_id: id,
    })

    if (error) {
      console.error('获取文章详情失败:', error)
      throw error
    }

    if (!data) {
      throw new Error('文章不存在或已下线')
    }

    // 解析返回的 JSON 数据
    const result = data as {
      article: Article
      images: ArticleImage[]
      related_articles: ArticleInfo[]
    }

    if (!result.article) {
      throw new Error('数据格式错误：缺少文章信息')
    }

    return {
      article: result.article,
      images: result.images || [],
      related_articles: result.related_articles || [],
    }
  }

  // 增加文章浏览量
  async incrementViewCount(articleId: string) {
    const { error } = await this.supabase.rpc('increment_view_count', { article_id: articleId })

    if (error) throw error
  }

  // 搜索文章（使用存储过程优化版本）
  async searchArticlesOptimized(query: string, limit = 10) {
    const { data, error } = await this.supabase.rpc('search_articles_optimized', {
      search_query: query,
      result_limit: limit,
    })

    if (error) {
      console.error('搜索文章失败:', error)
      throw error
    }

    return data || []
  }

  // 获取相关文章（使用存储过程优化版本）
  async getRelatedArticlesOptimized(articleId: string, limit = 3) {
    const { data, error } = await this.supabase.rpc('get_related_articles_optimized', {
      p_article_id: articleId,
      p_limit: limit,
    })

    if (error) {
      console.error('获取相关文章失败:', error)
      throw error
    }

    return data || []
  }

  // 获取文章统计信息（使用存储过程）
  async getArticleStatsOptimized() {
    const { data, error } = await this.supabase.rpc('get_article_stats')

    if (error) {
      console.error('获取文章统计失败:', error)
      throw error
    }

    return {
      totalArticles: data?.total_articles || 0,
      categories: data?.categories || [],
      tags: data?.popular_tags || [],
      recentArticles: data?.recent_articles || [],
    }
  }

  // 获取文章分类统计
  async getCategoryStats() {
    const { data, error } = await this.supabase
      .from('articles')
      .select('category')
      .eq('status', 'published')

    if (error) throw error

    const stats = data.reduce(
      (acc: Record<string, number>, article: { category?: string }) => {
        const category = article.category || '未分类'
        acc[category] = (acc[category] || 0) + 1
        return acc
      },
      {} as Record<string, number>,
    )

    return Object.entries(stats).map(([name, count]) => ({ name, count }))
  }

  // 获取热门标签
  async getPopularTags(limit = 20) {
    const { data, error } = await this.supabase
      .from('articles')
      .select('tags')
      .eq('status', 'published')

    if (error) throw error

    const allTags = data.flatMap((article: { tags?: string[] }) => article.tags || [])
    const tagStats = allTags.reduce(
      (acc: Record<string, number>, tag: string) => {
        acc[tag] = (acc[tag] || 0) + 1
        return acc
      },
      {} as Record<string, number>,
    )

    return Object.entries(tagStats)
      .sort(([, a], [, b]) => (b as number) - (a as number))
      .slice(0, limit)
      .map(([name, count]) => ({ name, count }))
  }

  // 上传图片到 Storage
  async uploadImage(file: File, path: string): Promise<string> {
    const { data, error } = await this.supabase.storage.from('article-images').upload(path, file)

    if (error) throw error

    const {
      data: { publicUrl },
    } = this.supabase.storage.from('article-images').getPublicUrl(data.path)

    return publicUrl
  }

  // 上传文章内容文件
  async uploadArticleContent(content: string, fileName: string): Promise<string> {
    const contentBlob = new Blob([content], { type: 'text/markdown' })

    const { data, error } = await this.supabase.storage
      .from('article-contents')
      .upload(fileName, contentBlob)

    if (error) throw error
    return data.path
  }

  // 获取项目列表（使用存储过程）
  async getProjects(status?: string, technology?: string, sortBy = 'default') {
    const { data, error } = await this.supabase.rpc('get_projects', {
      p_status: status || null,
      p_technology: technology || null,
      p_sort_by: sortBy,
    })

    if (error) {
      console.error('获取项目列表失败:', error)
      throw error
    }

    return {
      projects: data?.projects || [],
      technologies: data?.technologies || [],
      statusStats: data?.status_stats || { completed: 0, 'in-progress': 0, planned: 0 },
    }
  }

  // 下载简历文件
  async downloadResume(fileName: string = 'Resume_Lijianlin.pdf'): Promise<Blob> {
    const { data, error } = await this.supabase.storage.from('personal-info').download(fileName)

    if (error) {
      console.error('下载简历失败:', error)
      throw new Error(`下载简历失败: ${error.message}`)
    }

    if (!data) {
      throw new Error('简历文件不存在')
    }

    return data
  }

  // 获取简历文件的公共 URL
  async getResumeUrl(fileName: string = 'Resume_Lijianlin.pdf'): Promise<string> {
    const {
      data: { publicUrl },
    } = this.supabase.storage.from('personal-info').getPublicUrl(fileName)

    return publicUrl
  }
}

export default new SupabaseService()
export type { Article, ArticleImage, ArticleInfo, Project, TechnologyStat }
