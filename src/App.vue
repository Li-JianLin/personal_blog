<template>
  <div id="app">
    <el-container class="layout-container">
      <!-- 顶部导航 -->
      <el-header class="app-header">
        <div class="header-content">
          <div class="logo">
            <router-link to="/home" class="logo-link">
              <el-icon class="logo-icon"><IconCode /></el-icon>
              <span class="logo-text">李同学的小站</span>
            </router-link>
          </div>

          <!-- router开启el-menu的路由模式 -->
          <el-menu
            :default-active="$route.path"
            mode="horizontal"
            class="nav-menu"
            router
            :ellipsis="false"
          >
            <el-menu-item index="/home">
              <el-icon><HomeFilled /></el-icon>
              <span>首页</span>
            </el-menu-item>
            <el-menu-item index="/knowledge">
              <el-icon><Reading /></el-icon>
              <span>知识库</span>
            </el-menu-item>
            <el-menu-item index="/projects">
              <el-icon><Folder /></el-icon>
              <span>项目展示</span>
            </el-menu-item>
            <el-menu-item index="/about">
              <el-icon><UserFilled /></el-icon>
              <span>关于我</span>
            </el-menu-item>
          </el-menu>
        </div>
      </el-header>

      <!-- 主内容区域 -->
      <el-main class="app-main">
        <router-view />
      </el-main>

      <!-- 底部 -->
      <el-footer class="app-footer">
        <div class="footer-content">
          <p>&copy; 2025 李同学的小站. 基于 Vue3 + TypeScript + Element Plus 构建</p>
          <div class="social-links">
            <p>联系我</p>
            <!-- 微信 -->
            <div class="social-item wechat-container">
              <el-link>
                <el-icon>
                  <IconWechat />
                </el-icon>
                微信
              </el-link>
              <div class="qr-popup wechat-qr">
                <img src="@/assets/wechat-qr.png" alt="微信二维码" />
                <p>扫一扫添加微信</p>
              </div>
            </div>

            <!-- QQ -->
            <div class="social-item qq-container">
              <el-link>
                <el-icon>
                  <IconQQ />
                </el-icon>
                QQ
              </el-link>
              <div class="qr-popup qq-qr">
                <img src="@/assets/qq-qr.jpg" alt="QQ二维码" />
                <p>扫一扫添加QQ</p>
              </div>
            </div>
            <el-link :href="personalInfo.github" target="_blank">
              <el-icon>
                <IconGithub />
              </el-icon>
              GitHub
            </el-link>
            <el-link :href="'mailto:' + personalInfo.email">
              <el-icon><Message /></el-icon>
              邮箱
            </el-link>
          </div>
        </div>
      </el-footer>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { HomeFilled, Reading, Folder, UserFilled, Message } from '@element-plus/icons-vue'
import IconGithub from './components/icons/IconGithub.vue'
import IconWechat from './components/icons/IconWechat.vue'
import IconQQ from './components/icons/IconQQ.vue'
import IconCode from './components/icons/IconCode.vue'
import { usePortfolioStore } from '@/stores/portfolio'

// 在 App.vue 中使用 stores
const store = usePortfolioStore()
const personalInfo = store.personalInfo
</script>

<style scoped>
.layout-container {
  min-height: 100vh;
  width: 100%;
}

.app-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  width: 100%;
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 0;
  height: 60px;
  z-index: 1000;
}

.header-content {
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  padding: 0 24px;
}

.logo {
  display: flex;
  align-items: center;
}

.logo-link {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: #409eff;
  font-size: 18px;
  font-weight: bold;
  transition: all 0.3s;
}

.logo-link:hover {
  color: #337ecc;
}

.logo-icon {
  margin-right: 8px;
  font-size: 24px;
}

.logo-text {
  color: #303133;
}

.nav-menu {
  border-bottom: none;
}

.nav-menu .el-menu-item {
  border-bottom: 2px solid transparent;
  transition: all 0.3s;
  margin: 0 4px;
  border-radius: 4px 4px 0 0;
}

.nav-menu .el-menu-item:hover {
  background-color: #f5f7fa;
}

.nav-menu .el-menu-item.is-active {
  color: #409eff;
  border-bottom-color: #409eff;
  background-color: #ecf5ff;
}

.app-main {
  background: #f5f7fa;
  min-height: calc(100vh - 120px);
  margin-top: 60px;
  padding: 0;
  width: 100%;
}

.app-footer {
  background: #fff;
  border-top: 1px solid #e4e7ed;
  padding: 20px 0;
  height: auto;
}

.footer-content {
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
  color: #909399;
  font-size: 14px;
}

.social-links {
  display: flex;
  gap: 20px;
}

.social-item {
  position: relative;
}

.qr-popup {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: white;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
  z-index: 1000;
  margin-bottom: 8px;
  text-align: center;
  min-width: 120px;
}

.qr-popup img {
  width: 100px;
  height: 100px;
  border-radius: 4px;
  margin-bottom: 8px;
}

.qr-popup p {
  margin: 0;
  color: #606266;
  font-size: 12px;
}

.wechat-container:hover .wechat-qr,
.qq-container:hover .qq-qr {
  opacity: 1;
  visibility: visible;
  transform: translateX(-50%) translateY(-4px);
}

.social-links .el-link {
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s;
}

.social-links .el-link:hover {
  transform: translateY(-1px);
}

/* 超大屏幕 (≥1920px) */
@media (min-width: 1920px) {
  .header-content,
  .footer-content {
    padding: 0 48px;
  }

  .logo-link {
    font-size: 20px;
  }

  .logo-icon {
    font-size: 26px;
  }
}

/* 大屏幕 (1200px - 1919px) */
@media (min-width: 1200px) and (max-width: 1919px) {
  .header-content,
  .footer-content {
    padding: 0 32px;
  }
}

/* 中等屏幕 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .header-content,
  .footer-content {
    padding: 0 24px;
  }

  .nav-menu .el-menu-item {
    margin: 0 2px;
  }

  .nav-menu .el-menu-item span {
    font-size: 14px;
  }
}

/* 小屏幕 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .header-content,
  .footer-content {
    padding: 0 20px;
  }

  .logo-text {
    font-size: 18px;
  }

  .nav-menu .el-menu-item {
    margin: 0 1px;
    padding: 0 12px;
  }

  .nav-menu .el-menu-item span {
    font-size: 14px;
  }

  .footer-content {
    font-size: 13px;
  }

  .social-links {
    gap: 16px;
  }

  .qr-popup img {
    width: 90px;
    height: 90px;
  }

  .qr-popup p {
    font-size: 11px;
  }
}

/* 移动端 (≤767px) */
@media (max-width: 767px) {
  .app-header {
    height: auto;
    min-height: 60px;
  }

  .header-content {
    flex-direction: column;
    height: auto;
    padding: 12px 16px;
    gap: 12px;
  }

  .logo-text {
    font-size: 16px;
  }

  .logo-link {
    font-size: 16px;
  }

  .logo-icon {
    font-size: 20px;
    margin-right: 6px;
  }

  .nav-menu {
    width: 100%;
    justify-content: center;
  }

  .nav-menu .el-menu-item {
    margin: 0;
    flex: 1;
    justify-content: center;
    padding: 0 8px;
  }

  .nav-menu .el-menu-item span {
    font-size: 14px;
  }

  .app-main {
    min-height: calc(100vh - 140px);
    margin-top: 80px;
  }

  .footer-content {
    flex-direction: column;
    gap: 12px;
    text-align: center;
    padding: 0 16px;
    font-size: 12px;
  }

  .social-links {
    gap: 12px;
  }

  .qr-popup img {
    width: 80px;
    height: 80px;
  }

  .qr-popup p {
    font-size: 10px;
  }
}

/* 超小屏幕 (≤480px) */
@media (max-width: 480px) {
  .header-content {
    padding: 8px 12px;
  }

  .nav-menu .el-menu-item {
    padding: 0 4px;
  }

  .nav-menu .el-menu-item .el-icon {
    margin-right: 4px;
  }

  .nav-menu .el-menu-item span {
    font-size: 13px;
  }

  .footer-content {
    padding: 0 12px;
  }

  .social-links {
    gap: 8px;
  }
}

/* 横屏移动设备 */
@media (max-height: 500px) and (orientation: landscape) {
  .app-header {
    position: fixed;
  }

  .header-content {
    flex-direction: row;
    height: 50px;
    padding: 0 16px;
  }

  .nav-menu {
    margin-top: 0;
  }

  .app-main {
    min-height: calc(100vh - 100px);
    margin-top: 50px;
  }
}
</style>
