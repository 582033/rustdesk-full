<template>
  <a-layout :style="{'--sideBarWidth': sideBarWidth}" style="min-height: 100vh">
    <!-- Desktop Sidebar -->
    <a-layout-sider
        v-if="!appStore.setting.isMobile"
        :width="leftWidth"
        class="app-left"
        :trigger="null"
        collapsible
        v-model:collapsed="appStore.setting.sideIsCollapse"
    >
      <g-aside></g-aside>
      <div
        class="aside-trigger"
        :class="{'aside-trigger-collapsed': appStore.setting.sideIsCollapse}"
        @click="appStore.sideCollapse()"
        :style="{ left: (parseInt(leftWidth) - 10) + 'px' }"
      ></div>
    </a-layout-sider>

    <!-- Mobile Drawer -->
    <a-drawer
        v-else
        v-model:open="appStore.setting.drawerVisible"
        placement="left"
        :closable="false"
        :body-style="{ padding: 0 }"
        width="200px"
    >
      <g-aside></g-aside>
    </a-drawer>

    <a-layout class="app-container">
      <a-layout-header class="app-header" style="height: 50px; line-height: 50px;">
        <g-header></g-header>
      </a-layout-header>
      <div class="header-tags">
        <tags></tags>
      </div>
      <a-layout-content class="app-main">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <keep-alive :include="cachedTags">
              <component :is="Component"/>
            </keep-alive>
          </transition>
        </router-view>
      </a-layout-content>
    </a-layout>
  </a-layout>
</template>

<script setup>
  import { useAppStore } from '@/store/app'
  import { useTagsStore } from '@/store/tags'
  import { ref, computed } from 'vue'
  import Tags from '@/layout/components/tags/index.vue'
  import GAside from '@/layout/components/aside.vue'
  import GHeader from '@/layout/components/header.vue'

  const appStore = useAppStore()
  const tagStore = useTagsStore()
  const sideBarWidth = computed(() => appStore.setting.locale.sideBarWidth)
  const leftWidth = computed(() => appStore.setting.sideIsCollapse ? '64' : sideBarWidth.value.replace('px',''))

  const cachedTags = ref([])

  cachedTags.value = tagStore.cached
</script>

<style lang="scss" scoped>
.aside-trigger {
  position: fixed;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 20px;
  background-color: #f0f2f5;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 5px rgba(0,0,0,0.1);
  border: 1px solid #dcdfe6;
  transition: left 0.2s;

  &::before {
    content: '';
    display: block;
    width: 0;
    height: 0;
    border-top: 5px solid transparent;
    border-bottom: 5px solid transparent;
    border-right: 5px solid #909399;
    transition: transform 0.2s;
  }
}

.aside-trigger-collapsed {
  &::before {
    transform: rotate(180deg);
  }
}
.app-header {
  background-color: #ffffff;
  display: flex;
  height: 50px;
  justify-content: space-between;
  padding: 14px;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);
}

.header-tags {
  height: auto;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  padding: 6px 12px 0;
  background-color: #f0f2f5;
}

.app-left {
  background-color: #ffffff;
  transition: width 0.2s;
  position: relative;
}

.app-container {
  min-height: 100vh;
}

.app-main {
  padding: 12px;
}

/* fade transition */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
