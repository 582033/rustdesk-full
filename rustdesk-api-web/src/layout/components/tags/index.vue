<template>
  <a-tag v-for="(t, i) in tags"
         :key="t.name"
         class="tag"
         :closable="t.closeable"
         @close="close(t)"
         @click="toTag(t)"
         :class="{'active': t.active}"
  >
    {{ T(t.title) }}
  </a-tag>
</template>

<script>
  import { defineComponent, ref, onMounted, watch } from 'vue'
  import { useTagsStore } from '@/store/tags'
  import { useRoute, useRouter } from 'vue-router'
  import { T } from '@/utils/i18n'

  export default defineComponent({
    name: 'Index',
    setup () {
      const tags = ref([])
      const tagsStore = useTagsStore()
      const route = useRoute()
      const router = useRouter()
      tags.value = tagsStore.tags

      const addTag = (route) => {
        if (!route.meta?.hide && route.name) {
          tagsStore.addTag(route)
        }
      }
      const close = (tag) => {
        tagsStore.removeTag(tag)
        if (tag.active) {
          toLastTag()
        }
      }
      const toLastTag = () => {
        if (tags.value.length) {
          router.push({ name: tags.value[tags.value.length - 1].name })
        }
      }
      const init = () => {
        if (!tagsStore.tags.length) {
          tagsStore.initTags()
        }
        addTag(route)
      }

      const toTag = (tag) => {
        if (tag.name !== route.name) {
          router.push({ name: tag.name })
        }
      }

      onMounted(init)
      watch(route, (val) => {
        addTag(val)
      })
      return {
        tags,
        addTag,
        close,
        toLastTag,
        toTag,
        T,
      }
    },
  })
</script>

<style lang="scss" scoped>

.tag {
  cursor: pointer;
  padding: 6px 12px;
  margin-right: 8px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  transition: all 0.2s ease-in-out;
  background-color: #fafafa;

  &:hover {
    border-color: var(--primaryColor);
    color: var(--primaryColor);
  }

  &.active {
    background-color: var(--basicWhite);
    color: var(--primaryColor);
    border-color: #d9d9d9;
    border-bottom: 2px solid var(--primaryColor);
    border-radius: 4px 4px 0 0;
  }
}
</style>
