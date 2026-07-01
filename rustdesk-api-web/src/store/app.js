import { defineStore, acceptHMRUpdate } from 'pinia'
import logo from '@/assets/logo.png'
import zhCn from 'ant-design-vue/es/locale/zh_CN';
import en from 'ant-design-vue/es/locale/en_US';
import ko from 'ant-design-vue/es/locale/ko_KR';
import ru from 'ant-design-vue/es/locale/ru_RU';
import fr from 'ant-design-vue/es/locale/fr_FR';
import es from 'ant-design-vue/es/locale/es_ES';
import zhTw from 'ant-design-vue/es/locale/zh_TW';
import { admin, app, server } from '@/api/config'

const langs = {
  'zh-CN': { name: '中文', value: zhCn, sideBarWidth: '200px' },
  'en': { name: 'English', value: en, sideBarWidth: '200px' },
  'fr': { name: 'Français', value: fr, sideBarWidth: '200px' },
  'ko': { name: '한국어', value: ko, sideBarWidth: '200px' },
  'ru': { name: 'Русский', value: ru, sideBarWidth: '200px' },
  'es': { name: 'Español', value: es, sideBarWidth: '200px' },
  'zh-TW': { name: '中文繁体', value: zhTw, sideBarWidth: '200px' },
}
const defaultLang = localStorage.getItem('lang') || navigator.language || 'zh-CN'
export const useAppStore = defineStore({
  id: 'App',
  state: () => ({
    setting: {
      title: 'Rustdesk API Admin',
      hello: '',
      sideIsCollapse: false,
      logo,
      langs: langs,
      lang: defaultLang,
      locale: langs[defaultLang] ? langs[defaultLang] : langs['en'],
      isMobile: false,
      drawerVisible: false,
      appConfig: {
        web_client: 1,
      },
      rustdeskConfig: {
        'id_server': '',
        'key': '',
        'relay_server': '',
        'api_server': '',
      },
    },
  }),

  actions: {
    sideCollapse () {
      this.setting.sideIsCollapse = !this.setting.sideIsCollapse
    },
    setLang (lang) {
      console.log('setLang', lang)
      this.setting.lang = lang
      this.setting.locale = langs[lang]
      localStorage.setItem('lang', lang)
    },
    changeLang (v) {
      this.setLang(v)
    },
    setIsMobile (isMobile) {
      this.setting.isMobile = isMobile
    },
    toggleDrawer () {
      this.setting.drawerVisible = !this.setting.drawerVisible
    },
    loadConfig () {
      this.getAppConfig()
      this.getAdminConfig()
      this.loadRustdeskConfig()
    },
    getAppConfig () {
      console.log('getAppConfig')
      return app().then(res => {
        this.setting.appConfig = res.data
      })
    },
    getAdminConfig () {
      console.log('getAdminConfig')
      return admin().then(res => {
        this.replaceAdminTitle(res.data.title)
        this.setting.hello = res.data.hello
      })
    },
    replaceAdminTitle (newTitle) {
      document.title = document.title.replace(`- ${this.setting.title}`, `- ${newTitle}`)
      this.setting.title = newTitle
    },
    async loadRustdeskConfig () {
      console.log('loadRustdeskConfig')
      const res = await server().catch(_ => false)
      if (res) {
        this.setting.rustdeskConfig = res.data
        const prefix = 'wc-'
        localStorage.setItem(`${prefix}custom-rendezvous-server`, res.data.id_server)
        localStorage.setItem(`${prefix}key`, res.data.key)
        localStorage.setItem(`${prefix}api-server`, res.data.api_server)
      }

    },
  },
})

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useAppStore, import.meta.hot))
}
