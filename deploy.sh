#!/bin/bash

# Vercel 部署前的构建脚本

echo "🚀 开始构建项目..."

# 安装依赖
npm install

# 类型检查
echo "📝 检查 TypeScript 类型..."
npm run type-check

# 构建项目
echo "🔨 构建生产版本..."
npm run build

# 预览构建结果
echo "👀 预览构建结果..."
echo "构建完成！文件位于 dist/ 目录"
ls -la dist/

echo "✅ 构建成功！可以部署到 Vercel 了"
