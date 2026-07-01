<template>
  <a-card class="simple-card" :loading="form.loading">
    <template #title>
      <div class="card-header">
        <span>BLACK_LIST</span>
      </div>
    </template>
    <a-form :disabled="!canSend">
      <a-form-item>
        <a-textarea :value="form.list.join('|')" :rows="5" readonly></a-textarea>
      </a-form-item>
      <a-form-item>
        <a-button @click="getList">{{ T('Refresh') }}</a-button>
        <a-button @click="showForm('add')" type="primary" style="margin-left: 8px;">{{ T('Add') }}</a-button>
        <a-button @click="showForm('delete')" danger style="margin-left: 8px;">{{ T('Delete') }}</a-button>
      </a-form-item>
    </a-form>
    <a-modal v-model:open="form.form_visible" :title="form.form_type">
      <a-form layout="vertical">
        <a-form-item label="IP">
          <a-input v-model:value="form.form_input"></a-input>
          <div>多个IP以 | 分割</div>
          <div v-if="form.form_type==='delete'">, 全部填 <strong>all</strong></div>
        </a-form-item>
      </a-form>
      <template #footer>
        <a-button @click="form.form_visible=false">{{ T('Cancel') }}</a-button>
        <a-button @click="form.form_type === 'add' ? add() : remove()" type="primary">{{ T('Submit') }}</a-button>
      </template>
    </a-modal>
  </a-card>
</template>
<script setup>

  import { T } from '@/utils/i18n'
  import { reactive, watch } from 'vue'
  import { sendCmd } from '@/api/rustdesk'
  import { message } from 'ant-design-vue'
  import { RELAY_TARGET } from '@/views/rustdesk/options'

  const props = defineProps({
    canSend: Boolean,
  })

  const form = reactive({
    get_cmd: 'blacklist',
    add_cmd: 'blacklist-add',
    remove_cmd: 'blacklist-remove',
    list: [],
    target: RELAY_TARGET,
    loading: false,
    form_visible: false,
    form_input: '',
    form_type: '',
  })
  const getList = async () => {
    form.loading = true
    const res = await sendCmd({ cmd: form.get_cmd, target: RELAY_TARGET }).catch(_ => false)
    form.loading = false
    if (res) {
      form.list = res.data.split('\n').filter(i => i)
    }
  }
  const showForm = (type) => {
    form.form_visible = true
    form.form_input = ''
    form.form_type = type
  }
  const add = async () => {
    const res = await sendCmd({ cmd: form.add_cmd, option: form.form_input, target: RELAY_TARGET }).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      getList()
      form.form_visible = false
    }
  }
  const remove = async () => {
    const res = await sendCmd({ cmd: form.remove_cmd, option: form.form_input, target: RELAY_TARGET }).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      getList()
      form.form_visible = false
    }
  }
  watch(() => props.canSend, (v) => {
    if (v) {
      getList()
    }
  })


</script>
<style scoped lang="scss">

</style>
