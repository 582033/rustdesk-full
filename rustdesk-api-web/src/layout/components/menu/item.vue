<template>
  <a-sub-menu v-if="route.children && route.children.filter(c => !c.meta?.hide).length > 1 && route.children.some(r => !r.meta?.hide)"
              :key="route.name"
  >
    <template #title>
      <span>
        <component v-if="route.meta?.icon" :is="route.meta.icon" />
        <span>{{ T(route.meta?.title) || T(route.name) }}</span>
      </span>
    </template>
    <menu-item v-for="(_route,_index) in route.children"
               :route="_route"
               :key="_route.name">
    </menu-item>
  </a-sub-menu>
  <a-menu-item v-else-if="!parseRoute(route).meta?.hide" :key="parseRoute(route).name" @click="handleClick(parseRoute(route))">
    <component v-if="parseRoute(route).meta?.icon" :is="parseRoute(route).meta.icon" />
    <span>{{ T(parseRoute(route).meta?.title) || T(parseRoute(route).name) }}</span>
  </a-menu-item>
</template>

<script>
  import { defineComponent } from 'vue'
  import { T } from '@/utils/i18n'
  import { useRouter } from 'vue-router'

  export default defineComponent({
    name: 'MenuItem',
    props: {
      route: {},
    },
    mounted () {
    },
    setup (props) {
      const router = useRouter()
      //判断仅有一个子项的route
      const parseRoute = (route) => {
        if (route.children && route.children.filter(c => !c.meta?.hide).length === 1) {
          return { ...route.children.filter(c => !c.meta?.hide)[0], path: `${route.path}/${route.children.filter(c => !c.meta?.hide)[0].path}` }
        } else {
          return route
        }
      }

      const handleClick = (route) => {
        router.push({ name: route.name })
      }

      return {
        parseRoute,
        handleClick,
        T,
      }
    },
  })
</script>

<style lang="scss" scoped>
</style>
