import { createApp } from 'vue'
import App from './App.vue'
import { router } from '@/router'
import 'normalize.css/normalize.css'
import { pinia } from '@/store'
import '@/permission'
import '@/styles/style.scss'
import Antd from 'ant-design-vue';
import 'ant-design-vue/dist/reset.css';
import * as Icons from '@ant-design/icons-vue'


const app = createApp(App)
app.use(Antd)
app.use(pinia)
app.use(router)
for (const i in Icons) {
  app.component(i, Icons[i])
}
app.mount('#app')
