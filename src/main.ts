import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
// 引入 Element Plus 的中文语言包
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import 'element-plus/dist/index.css'
// 全局引入 Element Plus 图标
// import * as ElementPlusIconsVue from '@element-plus/icons-vue'

import App from './App.vue'
import router from './router'

const app = createApp(App)

// 注册所有图标
// for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
//   app.component(key, component)
// }

app.use(createPinia())
app.use(router)
// 使用 Element Plus 并设置语言为中文
app.use(ElementPlus, { locale: zhCn })

app.mount('#app')
