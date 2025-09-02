# 个人知识库兼个人展示网站

一个基于 Vue3 + TypeScript + Pinia + Element Plus 构建的现代化个人知识库和作品展示网站。

## 🌟 项目特色

- **现代化技术栈**: Vue3 + TypeScript + Pinia + Element Plus
- **响应式设计**: 适配桌面端和移动端
- **组件化架构**: 高度模块化的组件设计
- **类型安全**: 完整的 TypeScript 类型定义
- **优雅的UI**: 基于 Element Plus 的精美界面
- **SEO友好**: 良好的页面结构和语义化标签

## 🚀 功能模块

### 1. 首页 (Home)

- 个人介绍和技能展示
- 精选项目展示
- 最新文章推荐
- 技能水平可视化

### 2. 知识库 (Knowledge)

- 文章分类和标签系统
- 搜索和筛选功能
- 文章阅读时间估算
- 响应式卡片布局

### 3. 文章详情

- Markdown 内容渲染
- 文章目录导航
- 相关文章推荐
- 分享和返回顶部功能

### 4. 项目展示 (Projects)

- 项目状态分类管理
- 技术栈筛选
- 在线演示和源码链接
- 项目详情对话框

### 5. 关于我 (About)

- 详细的个人简历
- 教育背景时间线
- 技能专长展示
- 学习历程和个人特点

## 🛠️ 技术栈

- **前端框架**: Vue 3.5.17
- **开发语言**: TypeScript
- **状态管理**: Pinia 3.0.3
- **路由管理**: Vue Router 4.5.1
- **UI组件库**: Element Plus
- **图标库**: @element-plus/icons-vue
- **构建工具**: Vite 7.0.0
- **代码规范**: ESLint + Prettier

## 📦 项目结构

```
src/
├── assets/          # 静态资源
├── components/      # 公共组件
├── router/          # 路由配置
├── stores/          # Pinia状态管理
├── views/           # 页面组件
│   ├── HomeView.vue         # 首页
│   ├── KnowledgeView.vue    # 知识库
│   ├── ArticleDetailView.vue # 文章详情
│   ├── ProjectsView.vue     # 项目展示
│   ├── AboutView.vue        # 关于我
├── App.vue          # 根组件
└── main.ts          # 入口文件
```

## 🚀 快速开始

### 环境要求

- Node.js >= 18.0.0
- npm >= 8.0.0

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

### 类型检查

```bash
npm run type-check
```

### 代码检查和格式化

```bash
npm run lint
npm run format
```

## 📱 页面预览

### 首页

- 英雄区域展示个人信息和技能
- 技能水平进度条可视化
- 精选项目卡片展示
- 最新文章列表

### 知识库

- 搜索和分类筛选功能
- 文章卡片布局展示
- 标签云和阅读时间
- 分页功能

### 项目展示

- 项目状态和技术栈筛选
- 项目统计数据展示
- 在线演示和源码链接
- 技术栈可视化

### 关于页面

- 个人简介和联系信息
- 教育背景时间线
- 技能专长分类展示
- 学习历程和个人特点

### 联系页面

- 多种联系方式卡片
- 在线留言表单
- 常见问题折叠面板
- 回复时间说明

## 🎨 自定义配置

### 个人信息配置

在 `src/stores/portfolio.ts` 中修改个人信息：

```typescript
const personalInfo = ref({
  name: '你的姓名',
  title: '你的职位',
  email: 'your.email@example.com',
  phone: '你的电话',
  location: '你的位置',
  github: 'GitHub链接',
  linkedin: 'LinkedIn链接',
  avatar: '头像路径',
  introduction: '个人介绍',
})
```

### 技能配置

修改技能列表和水平：

```typescript
const skills = ref<Skill[]>([
  { name: '技能名称', level: 85, category: 'frontend' },
  // 添加更多技能...
])
```

### 项目配置

添加你的项目信息：

```typescript
const projects = ref<Project[]>([
  {
    id: 1,
    title: '项目标题',
    description: '项目描述',
    image: '项目图片',
    technologies: ['Vue3', 'TypeScript'],
    demoUrl: '演示链接',
    githubUrl: 'GitHub链接',
    status: 'completed',
  },
])
```

### 文章配置

添加你的文章内容：

```typescript
const articles = ref<Article[]>([
  {
    id: 1,
    title: '文章标题',
    summary: '文章摘要',
    content: '文章内容(支持Markdown)',
    category: '分类',
    tags: ['标签1', '标签2'],
    createDate: '2024-01-01',
    readTime: 10,
  },
])
```

## 🔧 开发建议

### 添加新页面

1. 在 `src/views/` 中创建新的 Vue 组件
2. 在 `src/router/index.ts` 中添加路由
3. 在导航菜单中添加链接

### 自定义样式

- 使用 Element Plus 的主题定制功能
- 在组件中使用 scoped CSS
- 遵循响应式设计原则

### 数据管理

- 使用 Pinia store 管理全局状态
- 为复杂数据结构定义 TypeScript 类型
- 使用计算属性优化性能

## 📄 部署

### Vercel 部署

1. 推送代码到 GitHub
2. 连接 Vercel 账户
3. 自动部署

### Netlify 部署

1. 构建项目: `npm run build`
2. 上传 `dist` 文件夹到 Netlify
3. 配置域名

### GitHub Pages 部署

1. 安装 gh-pages: `npm install --save-dev gh-pages`
2. 配置部署脚本
3. 运行部署命令

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进这个项目！

## 📜 许可证

MIT License

## 📞 联系方式

如果你对这个项目有任何问题或建议，欢迎联系我：

- 邮箱: your.email@example.com
- GitHub: [your-username](https://github.com/your-username)

---

⭐ 如果这个项目对你有帮助，请给它一个星标！
