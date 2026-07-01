<template>
  <div class="setting">

    <a-dropdown class="menu-item" :arrow="true">
      <div class="title">
        <GlobalOutlined style="font-size: 20px;" />
      </div>
      <template #overlay>
        <a-menu>
          <a-menu-item v-for="(v, k) in appStore.setting.langs" @click="changeLang(k)" :key="k">{{ v.name }}</a-menu-item>
        </a-menu>
      </template>
    </a-dropdown>
    <a-dropdown class="menu-item" :arrow="true">
      <div class="title">
        <span class="nickname">{{ user.username }}</span>
        <DownOutlined style="font-size: 12px; margin-left: 4px;" />
      </div>
      <template #overlay>
        <a-menu>
          <a-menu-item @click="showChangePwd">{{ T('ChangePassword') }}</a-menu-item>
          <a-menu-item @click="logout">{{ T('Logout') }}</a-menu-item>
        </a-menu>
      </template>
    </a-dropdown>
    <changePwdDialog v-model:visible="changePwdVisible"></changePwdDialog>
  </div>
</template>

<script setup>
  import { useUserStore } from '@/store/user'
  import { useAppStore } from '@/store/app'
  import changePwdDialog from '@/components/changePwdDialog.vue'
  import { ref } from 'vue'
  import { T } from '@/utils/i18n'
  

  const userStore = useUserStore()
  const user = userStore
  const appStore = useAppStore()

  const logout = () => {
    userStore.logout()
    window.location.reload()
  }

  const changePwdVisible = ref(false)
  const showChangePwd = () => {
    changePwdVisible.value = true
  }
  const changeLang = (v) => {
    appStore.changeLang(v)
  }
  
</script>

<style lang="scss" scoped>
.setting {
  margin-left: auto;
  display: flex;
  align-items: center;
  justify-content: space-around;

  .menu-item {
    margin-left: 15px;
    cursor: pointer;

    * {
      outline: none;
    }
  }

  .title {
    color: #000;
    display: flex;
    align-items: center;
    justify-content: space-around;


    .nickname {
      padding: 0 10px;
    }
  }
}
</style>