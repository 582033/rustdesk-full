<template>
  <a-config-provider :locale="appStore.setting.locale.value" :theme="{
    token: {
      colorPrimary: '#00A7A3',
    },
  }">
    <router-view />
  </a-config-provider>
</template>
<script setup>
import { useAppStore } from '@/store/app'
import { useBreakpoints } from '@vueuse/core'
import { watch } from 'vue'
const appStore = useAppStore()

const breakpoints = useBreakpoints({
  mobile: 768,
})
const isMobile = breakpoints.smaller('mobile')

watch(isMobile, (value) => {
  appStore.setIsMobile(value)
}, { immediate: true })
</script>
<style>
</style>
