<template>
  <a-menu
          class="menus"
          :inline-collapsed="isCollapse"
          v-model:selectedKeys="selectedKeys"
          theme="light"
          mode="inline"
  >
    <menu-item v-for="route in routes" :key="route.name" :route="route"></menu-item>
  </a-menu>
</template>

<script>
  import { defineComponent, ref, onMounted, watch, computed } from 'vue'
  import { useRouteStore } from '@/store/router'
  import MenuItem from '@/layout/components/menu/item.vue'
  import { useRoute } from 'vue-router'
  import { useAppStore } from '@/store/app'

  export default defineComponent({
    name: 'Menu',
    created () {
    },
    components: { MenuItem },
    setup () {
      const routes = ref([])
      const route = useRoute()
      const app = useAppStore()
      const isCollapse = computed(() => app.setting.sideIsCollapse)
      const selectedKeys = computed(() => [route.name])

      routes.value = useRouteStore().routes
      return {
        routes,
        selectedKeys,
        isCollapse,
      }
    },

  })
</script>

<style lang="scss" scoped>
  .menus {
    height: 100vh;
    border-right: none;
    &:not(.ant-menu-inline-collapsed) {
      width: var(--sideBarWidth);
    }
  }
</style>
<style>
</style>
