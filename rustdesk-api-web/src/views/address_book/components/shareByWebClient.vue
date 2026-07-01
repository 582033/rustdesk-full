<template>
  <a-form ref="shareform" :model="formData" layout="vertical">
    <a-form-item :label="T('ID')" name="id" :rules="[{ required: true }]">
      {{ formData.id }}
    </a-form-item>
    <a-form-item :label="T('Password')" name="password" :rules="[{ required: true }]">
      <a-input-password v-model:value="formData.password" />
    </a-form-item>
    <a-form-item :label="T('ExpireTime')" name="expire" :rules="[{ required: true }]">
      <a-select v-model:value="formData.expire">
        <a-select-option
            v-for="item in expireTimes"
            :key="item.value"
            :value="item.value"
        >{{ item.label }}</a-select-option>
      </a-select>
    </a-form-item>
    <a-form-item v-if="link" :label="T('Link')">
      <a-input-search v-model:value="link" readonly>
        <template #enterButton>
          <a-button @click="copyLink"><CopyOutlined /></a-button>
        </template>
      </a-input-search>
    </a-form-item>
    <a-form-item>
      <a-button v-if="!link" @click="cancel">{{ T('Cancel') }}</a-button>
      <a-button v-if="!link" :loading="loading" @click="submitShare" type="primary" style="margin-left: 8px;">{{ T('Submit') }}</a-button>
      <a-button v-else @click="cancel" type="primary">{{ T('Close') }}</a-button>
    </a-form-item>
  </a-form>
</template>

<script setup>
  import { T } from '@/utils/i18n'
  import { computed, reactive, ref, watch } from 'vue'
  import { getV2ShareUrl } from '@/utils/webclient'
  import * as sha256 from 'fast-sha256'
  import { shareByWebClient } from '@/api/address_book'
  import { handleClipboard } from '@/utils/clipboard'

  const props = defineProps({
    id: String,
    hash: String,
  })
  const emits = defineEmits(['cancel', 'success'])
  const formData = reactive({
    id: props.id,
    password_type: 'once',
    password: '',
    expire: 1800,
    hash: props.hash,
  })
  watch(() => props.id, () => {
    init()
  })
  const init = () => {
    formData.id = props.id
    formData.hash = props.hash
    formData.password = ''
    formData.expire = 1800
    formData.password_type = 'once'
    link.value = ''
  }
  const link = ref('')
  const expireTimes = computed(() => [
    { label: T('Minutes', { param: 5 }, 5), value: 300 },
    { label: T('Minutes', { param: 30 }, 30), value: 1800 },
    { label: T('Hours', { param: 1 }, 1), value: 3600 },
    { label: T('Days', { param: 1 }, 1), value: 86400 },
    { label: T('Weeks', { param: 1 }, 1), value: 604800 },
    { label: T('Months', { param: 1 }, 1), value: 2592000 },
    { label: T('Forever'), value: 0 },
  ])

  const cancel = () => {
    loading.value = false
    emits('cancel')
    init()
  }
  const loading = ref(false)
  const shareform = ref(null)
  const submitShare = () => {
    shareform.value.validate().then(async () => {
      loading.value = true
      const _formData = { ...formData }
      const res = await shareByWebClient(_formData).catch(_ => false)
      if (res) {
        link.value = getV2ShareUrl(res.data.share_token)
        emits('success')
      }
      loading.value = false
    })
  }

  const copyLink = (e) => {
    handleClipboard(link.value, e)
  }
</script>

<style scoped lang="scss">
</style>