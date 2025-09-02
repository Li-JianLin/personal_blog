# Supabase 存储过程 SQL 脚本

以下是需要在 Supabase 数据库中创建的存储过程，用于优化文章查询性能。

## 1. 获取分页文章列表（主要优化函数）
CREATE OR REPLACE FUNCTION get_articles_with_pagination(
  p_page INTEGER DEFAULT 1,
  p_page_size INTEGER DEFAULT 6,
  p_category TEXT DEFAULT NULL,
  p_search_query TEXT DEFAULT NULL,
  p_sort_by TEXT DEFAULT 'date'
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_offset INTEGER;
  v_total INTEGER;
  v_articles JSON;
  v_categories JSON;
  v_result JSON;
BEGIN
  -- 计算偏移量
  v_offset := (p_page - 1) * p_page_size;
  
  -- 构建查询条件并获取总数
  WITH filtered_articles AS (
    SELECT *
    FROM articles
    WHERE status = 'published'
      AND (p_category IS NULL OR category = p_category)
      AND (p_search_query IS NULL OR 
           title ILIKE '%' || p_search_query || '%' OR 
           summary ILIKE '%' || p_search_query || '%' OR
           array_to_string(tags, ' ') ILIKE '%' || p_search_query || '%')
  )
  SELECT COUNT(*) INTO v_total FROM filtered_articles;
  
  -- 获取分页文章数据（根据排序方式）
  IF p_sort_by = 'title' THEN
    -- 按标题排序
    WITH filtered_articles AS (
      SELECT *
      FROM articles
      WHERE status = 'published'
        AND (p_category IS NULL OR category = p_category)
        AND (p_search_query IS NULL OR 
             title ILIKE '%' || p_search_query || '%' OR 
             summary ILIKE '%' || p_search_query || '%' OR
             array_to_string(tags, ' ') ILIKE '%' || p_search_query || '%')
      ORDER BY title ASC
      LIMIT p_page_size OFFSET v_offset
    )
    SELECT json_agg(
      json_build_object(
        'id', id,
        'title', title,
        'slug', slug,
        'summary', summary,
        'category', category,
        'tags', tags,
        'cover_image_url', cover_image_url,
        'view_count', view_count,
        'reading_time', reading_time,
        'created_at', created_at,
        'updated_at', updated_at
      )
    ) INTO v_articles FROM filtered_articles;
    
  ELSIF p_sort_by = 'readTime' THEN
    -- 按阅读时间排序
    WITH filtered_articles AS (
      SELECT *
      FROM articles
      WHERE status = 'published'
        AND (p_category IS NULL OR category = p_category)
        AND (p_search_query IS NULL OR 
             title ILIKE '%' || p_search_query || '%' OR 
             summary ILIKE '%' || p_search_query || '%' OR
             array_to_string(tags, ' ') ILIKE '%' || p_search_query || '%')
      ORDER BY reading_time ASC, created_at DESC
      LIMIT p_page_size OFFSET v_offset
    )
    SELECT json_agg(
      json_build_object(
        'id', id,
        'title', title,
        'slug', slug,
        'summary', summary,
        'category', category,
        'tags', tags,
        'cover_image_url', cover_image_url,
        'view_count', view_count,
        'reading_time', reading_time,
        'created_at', created_at,
        'updated_at', updated_at
      )
    ) INTO v_articles FROM filtered_articles;
    
  ELSE
    -- 默认按发布时间排序
    WITH filtered_articles AS (
      SELECT *
      FROM articles
      WHERE status = 'published'
        AND (p_category IS NULL OR category = p_category)
        AND (p_search_query IS NULL OR 
             title ILIKE '%' || p_search_query || '%' OR 
             summary ILIKE '%' || p_search_query || '%' OR
             array_to_string(tags, ' ') ILIKE '%' || p_search_query || '%')
      ORDER BY created_at DESC
      LIMIT p_page_size OFFSET v_offset
    )
    SELECT json_agg(
      json_build_object(
        'id', id,
        'title', title,
        'slug', slug,
        'summary', summary,
        'category', category,
        'tags', tags,
        'cover_image_url', cover_image_url,
        'view_count', view_count,
        'reading_time', reading_time,
        'created_at', created_at,
        'updated_at', updated_at
      )
    ) INTO v_articles FROM filtered_articles;
  END IF;
  
  -- 获取分类统计
  WITH category_stats AS (
    SELECT 
      category,
      COUNT(*) as count
    FROM articles 
    WHERE status = 'published' AND category IS NOT NULL
    GROUP BY category
    ORDER BY count DESC, category
  )
  SELECT json_agg(
    json_build_object(
      'name', category,
      'count', count
    )
  ) INTO v_categories FROM category_stats;
  
  -- 构建返回结果
  v_result := json_build_object(
    'articles', COALESCE(v_articles, '[]'::json),
    'total_count', v_total,
    'categories', COALESCE(v_categories, '[]'::json)
  );
  
  RETURN v_result;
END;
$$;

-- 更新权限
GRANT EXECUTE ON FUNCTION get_articles_with_pagination TO anon, authenticated;


## 2. 优化的文章搜索函数
CREATE OR REPLACE FUNCTION search_articles_optimized(
  search_query TEXT,
  result_limit INTEGER DEFAULT 10
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSON;
BEGIN
  WITH search_results AS (
    SELECT 
      id, title, slug, summary, category, tags, cover_image_url, created_at,
      -- 计算搜索相关性得分
      CASE 
        WHEN title ILIKE '%' || search_query || '%' THEN 3
        WHEN summary ILIKE '%' || search_query || '%' THEN 2
        WHEN array_to_string(tags, ' ') ILIKE '%' || search_query || '%' THEN 1
        ELSE 0
      END as relevance_score
    FROM articles
    WHERE status = 'published'
      AND (
        title ILIKE '%' || search_query || '%' OR 
        summary ILIKE '%' || search_query || '%' OR
        array_to_string(tags, ' ') ILIKE '%' || search_query || '%'
      )
    ORDER BY relevance_score DESC, created_at DESC
    LIMIT result_limit
  )
  SELECT json_agg(
    json_build_object(
      'id', id,
      'title', title,
      'slug', slug,
      'summary', summary,
      'category', category,
      'tags', tags,
      'cover_image_url', cover_image_url,
      'created_at', created_at,
      'relevance_score', relevance_score
    )
  ) INTO v_result FROM search_results;
  
  RETURN COALESCE(v_result, '[]'::json);
END;
$$;


## 3. 优化的相关文章推荐函数


CREATE OR REPLACE FUNCTION get_related_articles_optimized(
  p_article_id UUID,
  p_limit INTEGER DEFAULT 3
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_category TEXT;
  v_tags TEXT[];
  v_result JSON;
BEGIN
  -- 获取当前文章的分类和标签
  SELECT category, tags INTO v_category, v_tags
  FROM articles WHERE id = p_article_id;
  
  IF v_category IS NULL THEN
    RETURN '[]'::json;
  END IF;
  
  WITH related_articles AS (
    SELECT 
      id, title, slug, summary, category, cover_image_url, created_at,
      -- 计算相关性得分
      CASE 
        WHEN category = v_category AND tags && v_tags THEN 3  -- 同分类且有相同标签
        WHEN category = v_category THEN 2                     -- 仅同分类
        WHEN tags && v_tags THEN 1                           -- 仅有相同标签
        ELSE 0
      END as relevance_score
    FROM articles
    WHERE status = 'published' 
      AND id != p_article_id
      AND (category = v_category OR tags && v_tags)
    ORDER BY relevance_score DESC, view_count DESC, created_at DESC
    LIMIT p_limit
  )
  SELECT json_agg(
    json_build_object(
      'id', id,
      'title', title,
      'slug', slug,
      'summary', summary,
      'category', category,
      'cover_image_url', cover_image_url,
      'created_at', created_at
    )
  ) INTO v_result FROM related_articles;
  
  RETURN COALESCE(v_result, '[]'::json);
END;
$$;


## 4. 文章统计信息函数


CREATE OR REPLACE FUNCTION get_article_stats()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
  v_categories JSON;
  v_tags JSON;
  v_recent JSON;
  v_result JSON;
BEGIN
  -- 获取文章总数
  SELECT COUNT(*) INTO v_total
  FROM articles WHERE status = 'published';
  
  -- 获取分类统计
  WITH category_stats AS (
    SELECT 
      category,
      COUNT(*) as count
    FROM articles 
    WHERE status = 'published' AND category IS NOT NULL
    GROUP BY category
    ORDER BY count DESC
  )
  SELECT json_agg(
    json_build_object(
      'name', category,
      'count', count
    )
  ) INTO v_categories FROM category_stats;
  
  -- 获取热门标签
  WITH tag_stats AS (
    SELECT 
      unnest(tags) as tag,
      COUNT(*) as count
    FROM articles 
    WHERE status = 'published' AND tags IS NOT NULL
    GROUP BY unnest(tags)
    ORDER BY count DESC
    LIMIT 10
  )
  SELECT json_agg(
    json_build_object(
      'name', tag,
      'count', count
    )
  ) INTO v_tags FROM tag_stats;
  
  -- 获取最新文章
  WITH recent_articles AS (
    SELECT id, title, slug, created_at
    FROM articles
    WHERE status = 'published'
    ORDER BY created_at DESC
    LIMIT 5
  )
  SELECT json_agg(
    json_build_object(
      'id', id,
      'title', title,
      'slug', slug,
      'created_at', created_at
    )
  ) INTO v_recent FROM recent_articles;
  
  -- 构建返回结果
  v_result := json_build_object(
    'total_articles', v_total,
    'categories', COALESCE(v_categories, '[]'::json),
    'popular_tags', COALESCE(v_tags, '[]'::json),
    'recent_articles', COALESCE(v_recent, '[]'::json)
  );
  
  RETURN v_result;
END;
$$;


## 使用说明

1. **在 Supabase Dashboard 中执行**: 
   - 进入 SQL Editor
   - 依次执行上述 SQL 语句创建存储过程

2. **权限设置**:

   -- 授权给匿名用户（如果需要）
   GRANT EXECUTE ON FUNCTION get_articles_with_pagination TO anon;
   GRANT EXECUTE ON FUNCTION search_articles_optimized TO anon;
   GRANT EXECUTE ON FUNCTION get_related_articles_optimized TO anon;
   GRANT EXECUTE ON FUNCTION get_article_stats TO anon;


3. **性能优化建议**:
   -- 创建索引以提升性能
   CREATE INDEX IF NOT EXISTS idx_articles_status_category ON articles(status, category);
   CREATE INDEX IF NOT EXISTS idx_articles_status_created_at ON articles(status, created_at DESC);
   CREATE INDEX IF NOT EXISTS idx_articles_title_search ON articles USING gin(to_tsvector('chinese', title));
   CREATE INDEX IF NOT EXISTS idx_articles_tags ON articles USING gin(tags);


## 5. 获取文章详情（完整版本，修复相关文章查询）
CREATE OR REPLACE FUNCTION get_article_detail(
  p_article_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_article JSON;
  v_images JSON;
  v_related_articles JSON;
  v_result JSON;
  v_article_category TEXT;
  v_article_tags TEXT[];
BEGIN
  -- 获取文章详情和基本信息
  SELECT row_to_json(a.*), a.category, a.tags 
  INTO v_article, v_article_category, v_article_tags
  FROM articles a
  WHERE a.id = p_article_id 
    AND a.status = 'published';
  
  -- 如果文章不存在，返回 null
  IF v_article IS NULL THEN
    RETURN NULL;
  END IF;
  
  -- 获取文章关联图片
  SELECT COALESCE(json_agg(
    json_build_object(
      'id', ai.id,
      'article_id', ai.article_id,
      'image_url', ai.image_url,
      'alt_text', ai.alt_text,
      'caption', ai.caption,
      'width', ai.width,
      'height', ai.height,
      'file_size', ai.file_size,
      'position_in_content', ai.position_in_content,
      'is_cover', ai.is_cover,
      'created_at', ai.created_at
    ) ORDER BY ai.position_in_content
  ), '[]'::json) INTO v_images
  FROM article_images ai
  WHERE ai.article_id = p_article_id;
  
  -- 获取相关文章（修复版本）
  SELECT COALESCE(json_agg(
    json_build_object(
      'id', ra.id,
      'title', ra.title,
      'slug', ra.slug,
      'summary', ra.summary,
      'category', ra.category,
      'tags', ra.tags,
      'cover_image_url', ra.cover_image_url,
      'view_count', ra.view_count,
      'reading_time', ra.reading_time,
      'created_at', ra.created_at,
      'updated_at', ra.updated_at
    )
  ), '[]'::json) INTO v_related_articles
  FROM (
    SELECT DISTINCT a.*,
      -- 计算相关性分数
      CASE 
        WHEN a.category = v_article_category THEN 2
        ELSE 0
      END +
      CASE 
        WHEN v_article_tags IS NOT NULL AND array_length(v_article_tags, 1) > 0 
             AND a.tags IS NOT NULL AND array_length(a.tags, 1) > 0 
             AND a.tags && v_article_tags THEN 1
        ELSE 0
      END as relevance_score
    FROM articles a
    WHERE a.id != p_article_id
      AND a.status = 'published'
      AND (
        a.category = v_article_category
        OR (
          v_article_tags IS NOT NULL 
          AND array_length(v_article_tags, 1) > 0 
          AND a.tags IS NOT NULL 
          AND array_length(a.tags, 1) > 0 
          AND a.tags && v_article_tags
        )
      )
    ORDER BY 
      relevance_score DESC,
      a.view_count DESC,
      a.created_at DESC
    LIMIT 6
  ) ra;
  
  -- 组合结果
  SELECT json_build_object(
    'article', v_article,
    'images', v_images,
    'related_articles', v_related_articles
  ) INTO v_result;
  
  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE LOG 'Error in get_article_detail_optimized: %', SQLERRM;
    RETURN NULL;
END;
$$;

## 6.获取项目列表
CREATE OR REPLACE FUNCTION get_projects(
  p_status TEXT DEFAULT NULL,
  p_technology TEXT DEFAULT NULL,
  p_sort_by TEXT DEFAULT 'default'
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_projects JSON;
  v_technologies JSON;
  v_status_stats JSON;
  v_result JSON;
BEGIN
  -- 获取项目数据（根据排序方式）
  IF p_sort_by = 'title' THEN
    -- 按标题排序
    WITH filtered_projects AS (
      SELECT 
        id,
        title,
        summary as description,
        cover_image_url as image,
        tags as technologies,
        status,
        category,
        created_at,
        updated_at,
        view_count,
        reading_time
      FROM articles
      WHERE status IN ('completed', 'in-progress', 'planned')
        AND (p_status IS NULL OR status = p_status)
        AND (p_technology IS NULL OR p_technology = ANY(tags))
      ORDER BY title ASC
    )
    SELECT json_agg(
      json_build_object(
        'id', id,
        'title', title,
        'description', description,
        'image', image,
        'technologies', technologies,
        'status', status,
        'category', category,
        'created_at', created_at,
        'updated_at', updated_at,
        'view_count', view_count,
        'reading_time', reading_time
      )
    ) INTO v_projects FROM filtered_projects;
    
  ELSIF p_sort_by = 'status' THEN
    -- 按状态排序（completed -> in-progress -> planned）
    WITH filtered_projects AS (
      SELECT 
        id,
        title,
        summary as description,
        cover_image_url as image,
        tags as technologies,
        status,
        category,
        created_at,
        updated_at,
        view_count,
        reading_time
      FROM articles
      WHERE status IN ('completed', 'in-progress', 'planned')
        AND (p_status IS NULL OR status = p_status)
        AND (p_technology IS NULL OR p_technology = ANY(tags))
      ORDER BY 
        CASE status
          WHEN 'completed' THEN 1
          WHEN 'in-progress' THEN 2
          WHEN 'planned' THEN 3
          ELSE 4
        END,
        created_at DESC
    )
    SELECT json_agg(
      json_build_object(
        'id', id,
        'title', title,
        'description', description,
        'image', image,
        'technologies', technologies,
        'status', status,
        'category', category,
        'created_at', created_at,
        'updated_at', updated_at,
        'view_count', view_count,
        'reading_time', reading_time
      )
    ) INTO v_projects FROM filtered_projects;
    
  ELSE
    -- 默认排序（按创建时间降序）
    WITH filtered_projects AS (
      SELECT 
        id,
        title,
        summary as description,
        cover_image_url as image,
        tags as technologies,
        status,
        category,
        created_at,
        updated_at,
        view_count,
        reading_time
      FROM articles
      WHERE status IN ('completed', 'in-progress', 'planned')
        AND (p_status IS NULL OR status = p_status)
        AND (p_technology IS NULL OR p_technology = ANY(tags))
      ORDER BY created_at DESC
    )
    SELECT json_agg(
      json_build_object(
        'id', id,
        'title', title,
        'description', description,
        'image', image,
        'technologies', technologies,
        'status', status,
        'category', category,
        'created_at', created_at,
        'updated_at', updated_at,
        'view_count', view_count,
        'reading_time', reading_time
      )
    ) INTO v_projects FROM filtered_projects;
  END IF;
  
  -- 获取所有技术栈统计
  WITH tech_stats AS (
    SELECT 
      unnest(tags) as technology,
      COUNT(*) as count
    FROM articles 
    WHERE status IN ('completed', 'in-progress', 'planned')
      AND tags IS NOT NULL
      AND array_length(tags, 1) > 0
    GROUP BY unnest(tags)
    ORDER BY count DESC, technology ASC
  )
  SELECT json_agg(
    json_build_object(
      'name', technology,
      'count', count
    )
  ) INTO v_technologies FROM tech_stats;
  
  -- 获取状态统计
  WITH status_stats AS (
    SELECT 
      status,
      COUNT(*) as count
    FROM articles
    WHERE status IN ('completed', 'in-progress', 'planned')
    GROUP BY status
  )
  SELECT json_build_object(
    'completed', COALESCE((SELECT count FROM status_stats WHERE status = 'completed'), 0),
    'in-progress', COALESCE((SELECT count FROM status_stats WHERE status = 'in-progress'), 0),
    'planned', COALESCE((SELECT count FROM status_stats WHERE status = 'planned'), 0)
  ) INTO v_status_stats;
  
  -- 构建返回结果
  v_result := json_build_object(
    'projects', COALESCE(v_projects, '[]'::json),
    'technologies', COALESCE(v_technologies, '[]'::json),
    'status_stats', COALESCE(v_status_stats, '{"completed": 0, "in-progress": 0, "planned": 0}'::json)
  );
  
  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE LOG 'Error in get_projects: %', SQLERRM;
    RETURN '{"projects": [], "technologies": [], "status_stats": {"completed": 0, "in-progress": 0, "planned": 0}}'::json;
END;
$$;


-- 授权给匿名用户和认证用户
GRANT EXECUTE ON FUNCTION get_projects TO anon, authenticated;

