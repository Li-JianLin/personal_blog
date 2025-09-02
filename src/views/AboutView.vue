<template>
  <div class="about-view">
    <div class="container">
      <!-- 个人简介区域 -->
      <section class="profile-section">
        <ProfileContent>
          <template #intro>
            <h1 class="profile-title">关于我</h1>
          </template>
        </ProfileContent>
      </section>

      <!-- 教育背景 -->
      <section class="education-section">
        <h2 class="section-title">教育背景</h2>
        <div class="timeline">
          <div class="timeline-item" v-for="value in educationInfo" :key="value.institution">
            <div class="timeline-dot"></div>
            <div class="timeline-content">
              <p class="timeline-time">{{ value.startDate }} - {{ value.endDate }}</p>
              <h3>{{ value.institution }} {{ value.fieldOfStudy }}（{{ value.degree }}）</h3>
              <p class="timeline-desc">
                {{ value.description }}
              </p>
            </div>
          </div>
        </div>
      </section>

      <section class="award-section">
        <h2 class="section-title">获奖经历</h2>
        <div class="timeline">
          <div class="timeline-item" v-for="value in awardInfo" :key="value.title">
            <div class="timeline-dot"></div>
            <div class="timeline-content">
              <p class="timeline-time">{{ value.date }}</p>
              <p class="timeline-desc">
                {{ value.title }}
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- 技能专长 -->
      <section class="skills-section">
        <h2 class="section-title">技能专长</h2>
        <TheSkill v-slot="{ skill }">
          <span class="skill-percentage">{{ skill.level }}%</span>
        </TheSkill>
      </section>

      <!-- 学习经历 -->
      <section class="learning-section">
        <h2 class="section-title">学习历程</h2>
        <div class="learning-grid">
          <div class="learning-card">
            <div class="card-icon">
              <el-icon><Reading /></el-icon>
            </div>
            <h3>基础学习阶段</h3>
            <p>从零开始学习HTML、CSS、JavaScript基础知识，通过大量练习掌握网页制作基本技能。</p>
            <ul>
              <li>HTML5语义化标签使用</li>
              <li>CSS3动画和布局技术</li>
              <li>JavaScript ES6+语法</li>
              <li>响应式设计原理</li>
            </ul>
          </div>

          <div class="learning-card">
            <div class="card-icon">
              <el-icon><Tools /></el-icon>
            </div>
            <h3>框架学习阶段</h3>
            <p>深入学习Vue3框架，掌握现代前端开发模式，理解组件化开发思想。</p>
            <ul>
              <li>Vue3组合式API</li>
              <li>组件设计模式</li>
              <li>状态管理(Pinia)</li>
              <li>路由管理</li>
            </ul>
          </div>

          <div class="learning-card">
            <div class="card-icon">
              <el-icon><Star /></el-icon>
            </div>
            <h3>项目实战阶段</h3>
            <p>通过实际项目开发巩固所学知识，培养解决实际问题的能力和项目经验。</p>
            <ul>
              <li>完整项目开发流程</li>
              <li>UI组件库使用</li>
              <li>性能优化实践</li>
              <li>部署上线经验</li>
            </ul>
          </div>
        </div>
      </section>

      <!-- 个人特点 -->
      <section class="characteristics-section">
        <h2 class="section-title">个人特点</h2>
        <div class="characteristics-grid">
          <div class="characteristic-item">
            <el-icon class="char-icon"><StarFilled /></el-icon>
            <h3>学习能力强</h3>
            <p>具备很强的自学能力，能够快速掌握新技术和新工具，持续关注前端技术发展趋势。</p>
          </div>

          <div class="characteristic-item">
            <el-icon class="char-icon"><Trophy /></el-icon>
            <h3>注重代码质量</h3>
            <p>重视代码的可读性和可维护性，遵循最佳实践，编写规范的代码。</p>
          </div>

          <div class="characteristic-item">
            <el-icon class="char-icon"><Connection /></el-icon>
            <h3>团队协作</h3>
            <p>具备良好的沟通能力和团队合作精神，能够与团队成员有效协作完成项目。</p>
          </div>
        </div>
      </section>

      <!-- 兴趣爱好 -->
      <!-- <section class="hobbies-section">
        <h2 class="section-title">兴趣爱好</h2>
        <div class="hobbies-list">
          <div class="hobby-item">
            <el-icon class="hobby-icon"><Monitor /></el-icon>
            <span>编程技术研究</span>
          </div>
          <div class="hobby-item">
            <el-icon class="hobby-icon"><Reading /></el-icon>
            <span>技术博客阅读</span>
          </div>
          <div class="hobby-item">
            <el-icon class="hobby-icon"><Platform /></el-icon>
            <span>开源项目贡献</span>
          </div>
          <div class="hobby-item">
            <el-icon class="hobby-icon"><ChatDotRound /></el-icon>
            <span>技术社区交流</span>
          </div>
          <div class="hobby-item">
            <el-icon class="hobby-icon"><Picture /></el-icon>
            <span>UI设计学习</span>
          </div>
          <div class="hobby-item">
            <el-icon class="hobby-icon"><VideoPlay /></el-icon>
            <span>在线课程学习</span>
          </div>
        </div>
      </section> -->

      <!-- 联系方式 -->
      <!-- <section class="contact-section">
        <h2 class="section-title">联系我</h2>
        <div class="contact-grid">
          <a :href="`mailto:${personalInfo.email}`" class="contact-card">
            <el-icon><Message /></el-icon>
            <span>发送邮件</span>
          </a>
          <a :href="personalInfo.github" target="_blank" class="contact-card">
            <el-icon><IconGithub /></el-icon>
            <span>GitHub</span>
          </a>
          <a :href="personalInfo.linkedin" target="_blank" class="contact-card">
            <el-icon><Link /></el-icon>
            <span>LinkedIn</span>
          </a>
          <div class="contact-card" @click="downloadResume">
            <el-icon><Download /></el-icon>
            <span>下载简历</span>
          </div>
        </div>
      </section> -->
    </div>
  </div>
</template>

<script setup lang="ts">
import { Reading, Tools, Star, StarFilled, Trophy, Connection } from '@element-plus/icons-vue'
import TheSkill from '@/components/TheSkill.vue'
import ProfileContent from '@/components/ProfileContent.vue'
import { usePortfolioStore } from '@/stores/portfolio'

const portfolioStore = usePortfolioStore()
const educationInfo = portfolioStore.educationInfo
const awardInfo = portfolioStore.awardInfo
</script>

<style scoped>
.about-view {
  min-height: 100vh;
  background: #f5f7fa;
}

.container {
  margin: 0 auto;
  padding: 40px 24px;
}

/* 个人简介区域 */
.profile-section {
  position: relative;
  /* 背景图片设置 */
  background: url('/src/assets/hero-bg.jpg') no-repeat fixed;
  background-size: cover;
  background-position: center center;
  color: white;
  padding: 60px 40px;
  border-radius: 12px;
  margin-bottom: 48px;
}

/* 为背景添加额外的遮罩层*/
.profile-section::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  z-index: 0;
  border-radius: 12px;
}

/* 确保文字层在遮罩层上方 */
.profile-section > * {
  position: relative;
  z-index: 1;
}

.profile-title {
  font-size: 3rem;
  font-weight: bold;
  margin-bottom: 16px;
}

/* 通用区域样式 */
section {
  background: white;
  margin-bottom: 48px;
  padding: 40px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

section:last-child {
  margin-bottom: 0;
}

.section-title {
  font-size: 2rem;
  text-align: center;
  margin-bottom: 32px;
  color: #303133;
  position: relative;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 3px;
  background: #409eff;
  border-radius: 2px;
}

/* 时间线 */
.timeline {
  position: relative;
  padding-left: 30px;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 10px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #409eff;
}

.timeline-item {
  position: relative;
  margin-bottom: 32px;
}

.timeline-dot {
  position: absolute;
  left: -24px;
  top: 8px;
  width: 12px;
  height: 12px;
  background: #409eff;
  border-radius: 50%;
  border: 3px solid white;
  box-shadow: 0 0 0 3px #409eff;
}

.timeline-content h3 {
  font-size: 1.25rem;
  color: #303133;
  margin-bottom: 8px;
}

.timeline-time {
  color: #409eff;
  font-size: 1rem;
  font-weight: 500;
  margin-bottom: 8px;
}

.timeline-desc {
  color: #606266;
  line-height: 1.6;
}

/* 技能区域 */
.skill-percentage {
  color: #909399;
  font-size: 0.9rem;
}

/* 学习经历 */
.learning-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
}

.learning-card {
  background: #f8f9fa;
  padding: 24px;
  border-radius: 8px;
  text-align: center;
  transition: transform 0.3s;
}

.learning-card:hover {
  transform: translateY(-4px);
}

.card-icon {
  font-size: 3rem;
  color: #409eff;
  margin-bottom: 16px;
}

.learning-card h3 {
  font-size: 1.25rem;
  color: #303133;
  margin-bottom: 12px;
}

.learning-card p {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 16px;
}

.learning-card ul {
  text-align: left;
  color: #606266;
  font-size: 0.9rem;
}

.learning-card li {
  margin-bottom: 4px;
}

/* 个人特点 */
.characteristics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
}

.characteristic-item {
  text-align: center;
  padding: 24px;
  background: #f8f9fa;
  border-radius: 8px;
  transition: transform 0.3s;
}

.characteristic-item:hover {
  transform: translateY(-2px);
}

.char-icon {
  font-size: 2.5rem;
  color: #409eff;
  margin-bottom: 16px;
}

.characteristic-item h3 {
  font-size: 1.1rem;
  color: #303133;
  margin-bottom: 12px;
}

.characteristic-item p {
  color: #606266;
  line-height: 1.6;
  font-size: 0.9rem;
}

/* 响应式设计 */
/* 超大屏幕优化 (≥1920px) */
@media (min-width: 1920px) {
  .container {
    padding: 60px 48px;
  }

  .profile-section {
    padding: 80px 60px;
  }

  .profile-title {
    font-size: 3.5rem;
  }

  .section-title {
    font-size: 2.5rem;
  }

  .learning-grid,
  .characteristics-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 32px;
  }
}

/* 大屏幕优化 (1200px - 1919px) */
@media (min-width: 1200px) and (max-width: 1919px) {
  .container {
    padding: 50px 32px;
  }

  .profile-section {
    padding: 70px 50px;
  }

  .learning-grid,
  .characteristics-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 28px;
  }
}

/* 中等屏幕优化 (992px - 1199px) */
@media (min-width: 992px) and (max-width: 1199px) {
  .container {
    padding: 40px 24px;
  }

  .profile-section {
    padding: 60px 40px;
  }

  .profile-title {
    font-size: 2.5rem;
  }

  .learning-grid,
  .characteristics-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
  }
}

/* 小屏幕优化 (768px - 991px) */
@media (min-width: 768px) and (max-width: 991px) {
  .container {
    padding: 30px 20px;
  }

  .profile-section {
    padding: 50px 30px;
  }

  .profile-title {
    font-size: 2.2rem;
  }

  .section-title {
    font-size: 1.8rem;
  }

  .learning-grid,
  .characteristics-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }
}

/* 移动端优化 (≤767px) */
@media (max-width: 767px) {
  .container {
    padding: 20px 16px;
  }

  .profile-section {
    padding: 40px 20px;
    margin-bottom: 32px;
  }

  .profile-title {
    font-size: 2rem;
  }

  .section-title {
    font-size: 1.6rem;
    margin-bottom: 24px;
  }

  .timeline-item {
    margin-bottom: 18px;
  }

  .learning-grid,
  .characteristics-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .timeline-content h3 {
    font-size: 1rem;
  }

  .timeline-content .timeline-desc {
    font-size: 0.9rem;
  }

  .award-section,
  .education-section,
  .skills-section,
  .learning-section,
  .characteristics-section {
    padding: 24px 16px;
    margin-bottom: 24px;
  }

  section {
    margin-bottom: 32px;
  }
}

/* 超小屏幕优化 (≤480px) */
@media (max-width: 480px) {
  .container {
    padding: 16px 12px;
  }

  .profile-section {
    padding: 30px 16px;
  }

  .profile-title {
    font-size: 1.8rem;
  }

  .section-title {
    font-size: 1.4rem;
  }

  .education-section,
  .skills-section,
  .learning-section,
  .characteristics-section {
    padding: 20px 12px;
    margin-bottom: 20px;
  }

  .timeline::before {
    left: 10px;
  }
}
</style>
