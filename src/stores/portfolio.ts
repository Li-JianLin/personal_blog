import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import avatarImg from '@/assets/avatar.jpg'

// 定义技能接口
export interface Skill {
  name: string
  level: number // 1-100
  category: 'frontend' | 'backend' | 'tools' | 'others'
}

export const usePortfolioStore = defineStore('portfolio', () => {
  // 个人信息
  const personalInfo = {
    name: '李建林',
    title: '前端开发工程师',
    email: 'lijianlin@csu.edu.cn',
    phone: '183-8486-8452',
    location: '湖南 长沙',
    github: 'https://github.com/Li-JianLin',
    avatar: avatarImg,
    introduction: `
      我是中南大学2026届应届毕业生，专注于前端开发技术。
      虽然不是计算机科班出身，但我通过自学掌握了现代Web开发技术栈，
      包括Vue3、TypeScript、前端工程化等。我热爱编程，注重代码质量，
      充满探索技术的热情，希望能够在前端开发领域发光发热。
    `,
  }

  // 教育经历
  const educationInfo = [
    {
      institution: '中南大学',
      degree: '工学硕士',
      fieldOfStudy: '地图制图学与地理信息工程',
      startDate: '2023年06月',
      endDate: '2026年06月',
      description:
        '学习前端开发技术，从HTML/CSS/JavaScript基础到Vue3、TypeScript等现代前端技术栈，开发个人博客网站，积累了实战经验。',
    },
    {
      institution: '成都理工大学',
      degree: '工学学士',
      fieldOfStudy: '资源勘查工程',
      startDate: '2019年09月',
      endDate: '2023年06月',
      description:
        '虽然不是计算机专业，但在校期间通过自学掌握了Python、SQL、VBA等编程基础，为后续转向前端开发打下了良好基础。',
    },
  ]

  const awardInfo = [
    { title: '第九届中国人工智能与大数据地球科学学术研讨会优秀报告', date: '2025年04月' },
    { title: '中南大学研究生学业奖学金二等奖', date: '2024年12月' },
    { title: '计算机技术与软件专业技术资格（中级-数据库系统工程师）', date: '2024年05月' },
    { title: '四川省优秀毕业生', date: '2023年06月' },
    { title: '国家励志奖学金（3次）', date: '2022年12月' },
    { title: '成都理工大学优秀共青团干部', date: '2022年04月' },
    { title: '成都理工大学优秀学生干部', date: '2021年12月' },
    { title: '全国大学生英语竞赛(NECCS)C类二等奖', date: '2021年05月' },
  ]

  // 技能列表
  // 创建一个响应式的数组，数组里的每一项都必须是 Skill 类型
  const skills = ref<Skill[]>([
    { name: 'Vue.js', level: 85, category: 'frontend' },
    { name: 'TypeScript', level: 80, category: 'frontend' },
    { name: 'JavaScript', level: 90, category: 'frontend' },
    { name: 'HTML5/CSS3', level: 90, category: 'frontend' },
    { name: 'Element Plus', level: 85, category: 'frontend' },
    { name: 'Pinia', level: 80, category: 'frontend' },
    { name: 'Vite', level: 75, category: 'tools' },
    { name: 'Git', level: 80, category: 'tools' },
    { name: 'Webpack', level: 70, category: 'tools' },
    { name: 'Python', level: 85, category: 'backend' },
    { name: 'Python', level: 90, category: 'backend' },
    { name: 'Node.js', level: 60, category: 'backend' },
    { name: 'Express', level: 55, category: 'backend' },
  ])

  // 计算属性：根据技能的category值，将技能分组
  const skillsByCategory = computed(() => {
    // 创建一个空对象，用于存储分类后的技能
    // 键是分类名（string），值是该分类下的技能数组（Skill[]）
    const categories: Record<string, Skill[]> = {}
    skills.value.forEach((skill) => {
      if (!categories[skill.category]) {
        categories[skill.category] = []
      }
      categories[skill.category].push(skill)
    })
    return categories
  })

  return {
    personalInfo,
    educationInfo,
    awardInfo,
    skills,
    skillsByCategory,
  }
})
