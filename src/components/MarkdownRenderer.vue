<template>
  <div class="markdown-renderer">
    <div v-html="renderedContent" class="markdown-content" @click="handleClick"></div>

    <!-- 图片预览弹窗 -->
    <el-dialog
      v-model="imagePreviewVisible"
      :width="'80%'"
      align-center
      :show-close="true"
      header-class="img-dialog-header"
      @close="closeImagePreview"
    >
      <template #header>
        <span>{{ currentImageCaption || '图片预览' }}</span>
      </template>
      <div class="image-preview-container">
        <img :src="currentImageUrl" :alt="currentImageAlt" class="preview-image" />
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { marked } from 'marked'
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css' // 使用 GitHub 主题
import { ElMessage } from 'element-plus'

interface Props {
  content: string | undefined
  images?: Array<{
    id: string
    image_url: string
    alt_text?: string
    caption?: string
    width?: number
    height?: number
  }>
}

const props = defineProps<Props>()

// 图片预览相关
const imagePreviewVisible = ref(false)
const currentImageUrl = ref('')
const currentImageAlt = ref('')
const currentImageCaption = ref('')

// 声明全局函数类型
declare global {
  interface Window {
    copyCode: (button: HTMLButtonElement) => void
    toggleCodeBlock: (button: HTMLButtonElement) => void
  }
}

// 配置 marked 和 highlight.js
onMounted(() => {
  // 添加全局复制函数
  window.copyCode = (button: HTMLButtonElement) => {
    const codeBlock = button.closest('.code-block')
    const codeContent = codeBlock?.querySelector('.code-content code')
    if (codeContent) {
      const text = codeContent.textContent || ''
      navigator.clipboard
        .writeText(text)
        .then(() => {
          const originalText = button.textContent
          button.textContent = '已复制!'
          button.style.background = '#67c23a'
          setTimeout(() => {
            button.textContent = originalText
            button.style.background = '#409eff'
          }, 2000)
        })
        .catch(() => {
          ElMessage.error('复制失败，请手动选择复制')
        })
    }
  }

  // 添加代码块折叠/展开功能
  window.toggleCodeBlock = (button: HTMLButtonElement) => {
    const codeBlock = button.closest('.code-block')
    if (!codeBlock) return

    const isCollapsed = codeBlock.classList.contains('collapsed')
    const icon = button.querySelector('.collapse-icon') // 展开按钮
    const text = button.querySelector('.collapse-text') // 展开文本
    const totalLines = codeBlock.getAttribute('data-lines') || '0'

    if (isCollapsed) {
      // 展开
      codeBlock.classList.remove('collapsed')
      codeBlock.classList.add('expanded')
      if (icon) icon.textContent = '▼'
      if (text) text.textContent = `折叠 (${totalLines} 行)`
      button.title = '折叠代码'
    } else {
      // 折叠
      codeBlock.classList.remove('expanded')
      codeBlock.classList.add('collapsed')
      if (icon) icon.textContent = '▶'
      if (text) text.textContent = `展开 (${totalLines} 行)`
      button.title = '展开代码'
    }
  }
})

// 渲染 Markdown 内容
const renderedContent = computed(() => {
  if (!props.content) return ''

  try {
    // 简化的处理方法：只在真正需要时转义 HTML 标签
    const processedContent = props.content

    // 重置标题索引，确保每次渲染都从 0 开始
    let headingIndex = 0

    // 创建新的渲染器实例，确保标题索引正确
    const renderer = new marked.Renderer()

    // 配置标题渲染器，自动添加 ID
    renderer.heading = ({ text, depth }: { text: string; depth: number }) => {
      const headingId = `heading-${headingIndex}`
      headingIndex++
      return `<h${depth} id="${headingId}">${text}</h${depth}>`
    }

    // 配置其他渲染器
    // 自定义代码块渲染
    renderer.code = ({ text, lang }: { text: string; lang?: string }) => {
      const validLanguage = lang && hljs.getLanguage(lang) ? lang : 'plaintext'
      const highlighted = hljs.highlight(text, { language: validLanguage }).value

      // 生成行号
      const lines = text.split('\n')
      const totalLines = lines.length
      const lineNumbers = lines
        .map((_, index) => `<span class="line-number">${index + 1}</span>`)
        .join('')

      // 生成代码行，确保每行都在独立的div中以便对齐
      const codeLines = highlighted
        .split('\n')
        .map(
          (line, index) => `<div class="code-line" data-line="${index + 1}">${line || ' '}</div>`,
        )
        .join('')

      // 判断是否需要折叠（超过10行）
      const needsCollapse = totalLines > 10
      const initialState = needsCollapse ? 'collapsed' : 'expanded'

      // 生成折叠按钮
      const collapseButton = needsCollapse
        ? `<button class="collapse-btn" onclick="toggleCodeBlock(this)" title="展开代码">
             <span class="collapse-icon">▶</span>
             <span class="collapse-text">展开 (${totalLines} 行)</span>
           </button>`
        : ''

      return `
        <div class="code-block collapsible ${initialState}" data-language="${validLanguage}" data-lines="${totalLines}">
          <div class="code-header">
            <span class="language-label">${lang || 'Text'}</span>
            <div class="header-controls">
              ${collapseButton}
              <button class="copy-btn" onclick="copyCode(this)">复制代码</button>
            </div>
          </div>
          <div class="code-container">
            <div class="line-numbers">${lineNumbers}</div>
            <div class="code-content-wrapper">
              <pre class="code-content"><code class="hljs language-${validLanguage}">${codeLines}</code></pre>
            </div>
          </div>
        </div>
      `
    }

    // 配置行内代码 - 处理 HTML 标签转义
    renderer.codespan = ({ text }: { text: string }) => {
      // 对行内代码中的 HTML 标签进行转义，防止被浏览器解析
      const escapedText = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      return `<code class="inline-code">${escapedText}</code>`
    }

    // 配置表格渲染器，添加包装器解决宽度问题
    const originalTable = renderer.table.bind(renderer)
    renderer.table = (token) => {
      const originalOutput = originalTable(token)
      return `<div class="table-wrapper">${originalOutput}</div>`
    }

    return marked(processedContent, {
      renderer: renderer,
      breaks: true,
      gfm: true,
    })
  } catch (error) {
    console.error('Markdown 渲染错误:', error)
    return '<p>内容渲染失败</p>'
  }
})

// 处理点击事件（图片预览和代码复制）
const handleClick = (event: Event) => {
  const target = event.target as HTMLElement

  // 处理图片点击预览
  if (target.tagName === 'IMG') {
    const img = target as HTMLImageElement
    currentImageUrl.value = img.getAttribute('data-original') || img.src
    currentImageAlt.value = img.alt
    currentImageCaption.value = img.getAttribute('data-caption') || ''
    imagePreviewVisible.value = true
  }
}

// 关闭图片预览
const closeImagePreview = () => {
  imagePreviewVisible.value = false
  currentImageUrl.value = ''
  currentImageAlt.value = ''
  currentImageCaption.value = ''
}
</script>

<style scoped>
.markdown-renderer {
  width: 100%;
  overflow-x: hidden; /* 防止横向滚动 */
}

.markdown-content {
  line-height: 1.8;
  color: #303133;
  font-size: 16px;
  max-width: 100%; /* 确保不超出容器 */
  overflow-x: hidden; /* 防止横向滚动 */
  word-wrap: break-word; /* 长单词换行 */
}

/* 标题样式 */
.markdown-content :deep(h1),
.markdown-content :deep(h2),
.markdown-content :deep(h3),
.markdown-content :deep(h4),
.markdown-content :deep(h5),
.markdown-content :deep(h6) {
  margin-top: 32px;
  margin-bottom: 16px;
  font-weight: 600;
  line-height: 1.3;
}

.markdown-content :deep(h1) {
  font-size: 2rem;
  color: #303133;
  padding-bottom: 8px;
  border-bottom: 2px solid #409eff;
}

.markdown-content :deep(h2) {
  font-size: 1.5rem;
  color: #409eff;
}

.markdown-content :deep(h3) {
  font-size: 1.25rem;
  color: #606266;
}

/* 段落样式 */
.markdown-content :deep(p) {
  margin-bottom: 16px;
  text-align: justify;
}

/* 文本样式 */
.markdown-content :deep(strong) {
  font-weight: 600;
  color: #303133;
}

.markdown-content :deep(em) {
  font-style: italic;
  color: #606266;
}

/* 列表样式 */
.markdown-content :deep(ul),
.markdown-content :deep(ol) {
  margin-bottom: 16px;
  padding-left: 24px;
}

.markdown-content :deep(li) {
  margin-bottom: 8px;
}

/* 引用样式 */
.markdown-content :deep(blockquote) {
  margin: 16px 0;
  padding: 16px 20px;
  background: #f8f9fa;
  border-left: 4px solid #409eff;
  color: #606266;
  font-style: italic;
}

/* 图片样式 */
.markdown-content :deep(.markdown-image) {
  margin: 24px 0;
  text-align: center;
  max-width: 100%; /* 确保图片容器不超出 */
  overflow: hidden; /* 防止图片溢出 */
}

/* 通用图片样式 - 确保所有图片都适配容器 */
.markdown-content :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
  display: block; /* 避免内联元素的间隙问题 */
  margin: 0 auto; /* 居中显示 */
}

.markdown-content :deep(.content-image) {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
}

.markdown-content :deep(.content-image:hover),
.markdown-content :deep(img:hover) {
  transform: scale(1.02);
  cursor: pointer;
}

.markdown-content :deep(figcaption) {
  margin-top: 8px;
  font-size: 14px;
  color: #909399;
  font-style: italic;
}

/* 代码块样式 */
.markdown-content :deep(.code-block) {
  margin: 20px 0;
  border-radius: 8px;
  overflow: hidden;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  max-width: 100%;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.markdown-content :deep(.code-header) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 16px;
  background: #2d3748;
  color: #e2e8f0;
  font-size: 13px;
  border-bottom: 1px solid #4a5568;
}

.markdown-content :deep(.language-label) {
  font-weight: 600;
  color: #64b5f6;
  text-transform: uppercase;
  font-size: 12px;
  letter-spacing: 0.5px;
}

.markdown-content :deep(.header-controls) {
  display: flex;
  align-items: center;
  gap: 8px;
}

.markdown-content :deep(.collapse-btn) {
  padding: 4px 8px;
  background: #718096;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 4px;
}

.markdown-content :deep(.collapse-btn:hover) {
  background: #4a5568;
}

.markdown-content :deep(.collapse-icon) {
  font-size: 10px;
  transition: transform 0.3s ease;
}

.markdown-content :deep(.copy-btn) {
  padding: 6px 12px;
  background: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.markdown-content :deep(.copy-btn:hover) {
  background: #337ecc;
  transform: translateY(-1px);
}

.markdown-content :deep(.code-container) {
  display: flex;
  background: #1e1e1e;
  overflow: hidden;
  max-width: 100%;
  transition: max-height 0.3s ease;
}

/* 折叠状态样式 */
.markdown-content :deep(.code-block.collapsed .code-container) {
  max-height: 200px;
  overflow: hidden;
  position: relative;
}

.markdown-content :deep(.code-block.collapsed .code-container::after) {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 40px;
  background: linear-gradient(transparent, #1e1e1e);
  pointer-events: none;
}

/* 代码块展开时，不限制最大高度 */
.markdown-content :deep(.code-block.expanded .code-container) {
  max-height: none;
  overflow-x: auto;
}

.markdown-content :deep(.line-numbers) {
  background: #2d2d2d;
  color: #858585;
  padding: 12px 0;
  font-family: 'Fira Code', 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.4;
  text-align: right;
  user-select: none;
  min-width: 50px;
  border-right: 1px solid #444;
  flex-shrink: 0;
}

.markdown-content :deep(.line-number) {
  display: block;
  padding: 0 8px;
  height: 1.4em;
}

.markdown-content :deep(.code-content-wrapper) {
  flex: 1;
  overflow-x: auto;
  min-width: 0;
}

.markdown-content :deep(.code-content) {
  margin: 0;
  padding: 12px 16px;
  background: #1e1e1e;
  font-family: 'Fira Code', 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.4;
  overflow: visible;
}

.markdown-content :deep(.code-line) {
  display: block;
  height: 1.4em;
  min-height: 1.4em;
  white-space: pre;
}

.markdown-content :deep(.hljs) {
  background: transparent !important;
  padding: 0 !important;
  color: #d4d4d4;
  margin: 0;
}

/* 行内代码样式 */
.markdown-content :deep(.inline-code) {
  padding: 2px 6px;
  background: #f1f3f4;
  border-radius: 4px;
  color: #e83e8c;
  font-family: 'Fira Code', 'Courier New', monospace;
  font-size: 0.9em;
  word-wrap: break-word;
}

/* 重写部分 highlight.js 主题以适配深色背景 */
.markdown-content :deep(.hljs-keyword) {
  color: #569cd6 !important;
}

.markdown-content :deep(.hljs-string) {
  color: #ce9178 !important;
}

.markdown-content :deep(.hljs-comment) {
  color: #6a9955 !important;
  font-style: italic;
}

.markdown-content :deep(.hljs-number) {
  color: #b5cea8 !important;
}

.markdown-content :deep(.hljs-function) {
  color: #dcdcaa !important;
}

.markdown-content :deep(.hljs-variable) {
  color: #9cdcfe !important;
}

.markdown-content :deep(.hljs-title) {
  color: #dcdcaa !important;
}

/* 表格样式 */
.markdown-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 16px 0;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  table-layout: auto; /* 自动调整列宽 */
  display: table; /* 保持表格的正常显示 */
}

/* 表格外层容器，处理溢出 */
.markdown-content :deep(.table-wrapper) {
  overflow-x: auto;
  margin: 16px 0;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* 包装器内的表格样式 */
.markdown-content :deep(.table-wrapper table) {
  width: 100%;
  border-collapse: collapse;
  margin: 0; /* 移除外边距，由包装器控制 */
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: none; /* 移除阴影，由包装器控制 */
  table-layout: auto; /* 自动调整列宽 */
  display: table; /* 保持表格的正常显示 */
  min-width: 100%; /* 确保表格至少占满容器宽度 */
}

.markdown-content :deep(th),
.markdown-content :deep(td) {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #ebeef5;
  white-space: nowrap; /* 防止单元格内容换行 */
  min-width: 120px; /* 设置最小宽度 */
}

.markdown-content :deep(th) {
  background: #f5f7fa;
  font-weight: 600;
  color: #303133;
  white-space: nowrap; /* 确保表头不换行 */
}

/* 特殊处理：当单元格内容较长时允许换行 */
.markdown-content :deep(td.wrap-content),
.markdown-content :deep(th.wrap-content) {
  white-space: normal;
  word-wrap: break-word;
}

/* 链接样式 */
.markdown-content :deep(a) {
  color: #409eff;
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: all 0.3s;
}

.markdown-content :deep(a:hover) {
  border-bottom-color: #409eff;
}

/* 图片预览样式 */
.img-dialog-header span {
  color: #409eff;
  font-size: 16px;
  font-weight: 500;
}

.image-preview-container {
  text-align: center;
}

.preview-image {
  max-width: 100%;
  max-height: 80vh;
  object-fit: contain;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .markdown-content {
    font-size: 15px;
    overflow-x: hidden; /* 移动端防止横向滚动 */
  }

  .markdown-content :deep(h1) {
    font-size: 1.8rem;
    word-wrap: break-word;
  }

  .markdown-content :deep(h2) {
    font-size: 1.4rem;
    word-wrap: break-word;
  }

  .markdown-content :deep(h3) {
    font-size: 1.2rem;
    word-wrap: break-word;
  }

  /* 移动端代码块样式优化 */
  .markdown-content :deep(.code-block) {
    margin: 16px 0;
    border-radius: 6px;
  }

  .markdown-content :deep(.code-header) {
    padding: 8px 12px;
    font-size: 11px;
    flex-wrap: wrap;
    gap: 8px;
  }

  .markdown-content :deep(.language-label) {
    font-size: 10px;
  }

  .markdown-content :deep(.header-controls) {
    gap: 6px;
  }

  .markdown-content :deep(.collapse-btn) {
    padding: 3px 6px;
    font-size: 10px;
  }

  .markdown-content :deep(.copy-btn) {
    padding: 4px 8px;
    font-size: 10px;
  }

  .markdown-content :deep(.code-container) {
    overflow-x: auto;
  }

  .markdown-content :deep(.line-numbers) {
    padding: 8px 0;
    font-size: 11px;
    min-width: 35px;
  }

  .markdown-content :deep(.line-number) {
    padding: 0 4px;
    height: 1.3em;
  }

  .markdown-content :deep(.code-content) {
    padding: 8px 12px;
    font-size: 11px;
    line-height: 1.3;
  }

  .markdown-content :deep(.code-line) {
    height: 1.3em;
    min-height: 1.3em;
  }

  .markdown-content :deep(.inline-code) {
    font-size: 0.85em;
    padding: 1px 4px;
  }

  /* 移动端折叠状态调整 */
  .markdown-content :deep(.code-block.collapsed .code-container) {
    max-height: 150px;
  }

  .markdown-content :deep(.table-wrapper) {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch; /* iOS 平滑滚动 */
  }

  .markdown-content :deep(.table-wrapper table) {
    font-size: 14px;
    min-width: max-content; /* 确保表格内容不被压缩 */
  }

  .markdown-content :deep(th),
  .markdown-content :deep(td) {
    padding: 8px 12px;
    min-width: 80px; /* 设置最小宽度 */
  }

  /* 移动端图片样式优化 */
  .markdown-content :deep(img) {
    max-width: 100%;
    height: auto;
    width: auto; /* 确保宽度自适应 */
    border-radius: 6px; /* 移动端稍小的圆角 */
    margin: 16px auto; /* 移动端减少外边距 */
  }

  .markdown-content :deep(.markdown-image) {
    margin: 16px 0; /* 移动端减少外边距 */
  }

  /* 长链接处理 */
  .markdown-content :deep(a) {
    word-wrap: break-word;
    overflow-wrap: break-word;
  }

  /* 长文本处理 */
  .markdown-content :deep(p) {
    word-wrap: break-word;
    overflow-wrap: break-word;
  }
}
</style>
