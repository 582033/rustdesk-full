<template>
  <a-card class="simple-card" :loading="form.loading">
    <template #title>
      <div class="card-header">
        <span>ALWAYS_USE_RELAY</span>
      </div>
    </template>
    <a-form :disabled="!canSend">
      <a-form-item>
        <a-switch v-model:checked="form.option" checked-value="Y" un-checked-value="N"></a-switch>
      </a-form-item>
      <a-form-item>
        <a-button @click="get">{{ T('Refresh') }}</a-button>
        <a-button @click="save" type="primary" style="margin-left: 8px;">{{ T('Save') }}</a-button>
      </a-form-item>
    </a-form>
  </a-card>
</template>
<script setup>

  import { T } from '@/utils/i18n'
  import { reactive, watch } from 'vue'
  import { sendCmd } from '@/api/rustdesk'
  import { message } from 'ant-design-vue'
  import { ID_TARGET } from '@/views/rustdesk/options'

  const emits = defineEmits('success')
  const props = defineProps({
    canSend: Boolean,
  })

  const form = reactive({
    cmd: 'aur',
    option: '',
    target: ID_TARGET,
    value: 0,
    loading: false,
  })
  const get = async () => {
    form.loading = true
    const res = await sendCmd({ cmd: 'aur', target: ID_TARGET }).catch(_ => false)
    form.loading = false
    if (res) {
      if (res.data === 'ALWAYS_USE_RELAY: true' || res.data === 'ALWAYS_USE_RELAY: true\n') {
        form.option = 'Y'
      } else {
        form.option = 'N'
      }
    }
  }
  const save = async () => {
    const res = await sendCmd(form).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      emits('success')
    }
  }

  watch(() => props.canSend, (v) => {
    if (v) {
      get()
    }
  })
</script>


<style scoped lang="scss">

</style>
