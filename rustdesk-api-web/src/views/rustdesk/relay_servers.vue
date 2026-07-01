<template>
  <a-card class="simple-card" :loading="form.loading">
    <template #title>
      <div class="card-header">
        <span>RELAY_SERVERS</span>
      </div>
    </template>
    <a-form :disabled="!canSend">
      <a-form-item>
        <a-input v-model:value="form.option"></a-input>
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

  const props = defineProps({
    canSend: Boolean,
  })


  const form = reactive({
    cmd: 'rs',
    option: '',
    target: ID_TARGET,
    loading: false,
  })
  const get = async () => {
    form.loading = true
    const res = await sendCmd({ cmd: 'rs', target: ID_TARGET }).catch(_ => false)
    form.loading = false
    if (res) {
      const data = res.data.split('\n').filter(i => i)
      form.option = data.join(',')
    }
  }
  const save = async () => {
    const res = await sendCmd(form).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
    }
  }
  watch(() => props.canSend, (v) => {
    if (v) {
      get()
    }
  })
  //为了在设置always_use_relay之后自动重新保存，防止被重置
  defineExpose({
    save,
  });
</script>
<style scoped lang="scss">

</style>
