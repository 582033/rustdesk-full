<template>
  <div>
    <h5>
      <span>ID {{ T('Status') }}: </span>
      <a-tag v-if="canSendIdServerCmd" color="success">{{ T('Available') }}</a-tag>
      <a-tag v-else color="error">{{ T('NotAvailable') }}</a-tag>
      <a-button size="small" type="link" @click="refreshCanSendIdServerCmd">{{ T('Refresh') }}</a-button>
    </h5>
    <h5>
      <span>RELAY {{ T('Status') }}: </span>
      <a-tag v-if="canSendRelayServerCmd" color="success">{{ T('Available') }}</a-tag>
      <a-tag v-else color="error">{{ T('NotAvailable') }}</a-tag>
      <a-button size="small" type="link" @click="refreshCanSendRelayServerCmd">{{ T('Refresh') }}</a-button>
    </h5>
    <a-tabs v-model:activeKey="activeName" type="card">
      <a-tab-pane key="Simple" :tab="T('Simple')">
        <a-space wrap>
          <RelayServers ref="rs" :can-send="canSendIdServerCmd" />
          <alwaysUseRelay :can-send="canSendIdServerCmd" @success="handleAlwaysUseRelaySuccess" />
          <mustLogin :can-send="canControlMustLogin&&canSendIdServerCmd" />
          <usage :can-send="canSendRelayServerCmd" />
          <blocklist :can-send="canSendRelayServerCmd" />
          <blacklist :can-send="canSendRelayServerCmd" />
        </a-space>
      </a-tab-pane>
      <a-tab-pane key="Advanced" :tab="T('Advanced')">
        <a-card class="list-query" :bordered="false">
          <a-form layout="inline">
            <a-form-item>
              <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
              <a-button type="primary" @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
              <a-button type="primary" :disabled="!canSendIdServerCmd" @click="showCmd({cmd:'',option:'',target:ID_TARGET})" style="margin-left: 8px;">{{ T('Send') }} To Id</a-button>
              <a-button type="primary" :disabled="!canSendRelayServerCmd" @click="showCmd({cmd:'',option:'',target:RELAY_TARGET})" style="margin-left: 8px;">{{ T('Send') }} To Relay</a-button>
            </a-form-item>
          </a-form>
        </a-card>
        <a-card class="list-body" :bordered="false">
          <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" rowKey="id">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'actions'">
                <a-button type="primary" :disabled="!canSendCmd(record.target)" @click="showCmd(record)">{{ T('Send') }}</a-button>
                <a-button v-if="record.id" @click="toUpdate(record)" style="margin-left: 8px;">{{ T('Edit') }}</a-button>
                <a-button v-if="record.id" type="primary" danger @click="del(record)" style="margin-left: 8px;">{{ T('Delete') }}</a-button>
              </template>
            </template>
          </a-table>

          <a-modal v-model:open="formVisible" :title="!formData.id ? T('Create') : T('Update')" @ok="submit" @cancel="formVisible = false">
            <a-form :model="formData" layout="vertical" style="margin-top: 20px;">
              <a-form-item label="cmd" name="cmd" :rules="[{ required: true }]"><a-input v-model:value="formData.cmd" /></a-form-item>
              <a-form-item label="alias" name="alias"><a-input v-model:value="formData.alias" /></a-form-item>
              <a-form-item label="option" name="option"><a-input v-model:value="formData.option" /></a-form-item>
              <a-form-item label="target" name="target" :rules="[{ required: true }]">
                <a-radio-group v-model:value="formData.target">
                  <a-radio value="21115">id_server</a-radio>
                  <a-radio value="21117">relay_server</a-radio>
                </a-radio-group>
              </a-form-item>
              <a-form-item label="explain" name="explain"><a-input v-model:value="formData.explain" /></a-form-item>
            </a-form>
          </a-modal>

          <a-modal v-model:open="showCmdForm" :title="T('SendCmd')" @ok="submitCmd" @cancel="showCmdForm = false">
            <a-form :model="customCmd" layout="vertical" style="margin-top: 20px;">
              <a-form-item label="cmd"><a-input v-model:value="customCmd.cmd" /></a-form-item>
              <a-form-item label="option">
                <a-input v-model:value="customCmd.option" />
                <a-typography-text v-if="customCmd.example.trim()" style="margin-top: 5px;">Example:
                  <a-typography-text type="primary">{{ customCmd.example }}</a-typography-text>
                </a-typography-text>
              </a-form-item>
              <a-form-item :label="T('Result')"><a-textarea v-model:value="customCmd.res" readonly :rows="15" /></a-form-item>
            </a-form>
          </a-modal>
        </a-card>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup>
  import { create, list, remove, sendCmd, update } from '@/api/rustdesk'
  import { onMounted, reactive, ref, h } from 'vue'
  import { T } from '@/utils/i18n'
  import { message, Modal } from 'ant-design-vue'
  import { ExclamationCircleOutlined } from '@ant-design/icons-vue'
  import { ID_TARGET, RELAY_TARGET } from '@/views/rustdesk/options'
  import blocklist from '@/views/rustdesk/blocklist.vue'
  import blacklist from '@/views/rustdesk/blacklist.vue'
  import alwaysUseRelay from '@/views/rustdesk/always_use_relay.vue'
  import RelayServers from '@/views/rustdesk/relay_servers.vue'
  import mustLogin from '@/views/rustdesk/must_login.vue'
  import usage from '@/views/rustdesk/usage.vue'

  const activeName = ref('Simple')

  const canSendIdServerCmd = ref(false)
  const checkCanSendIdServerCmd = async () => {
    const res = await sendCmd({ cmd: 'h', target: ID_TARGET }).catch(_ => false)
    canSendIdServerCmd.value = !!res.data
    if (canSendIdServerCmd.value) {
      const commands = res.data.split('\n').filter(i => i)
      console.log(commands)
      canControlMustLogin.value = commands.some(i => i.includes('must-login'))
    }
  }

  const canControlMustLogin = ref(false)
  const refreshCanSendIdServerCmd = () => {
    checkCanSendIdServerCmd()
  }
  onMounted(refreshCanSendIdServerCmd)

  const canSendRelayServerCmd = ref(false)
  const checkCanSendRelayServerCmd = async () => {
    const res = await sendCmd({ cmd: 'h', target: RELAY_TARGET }).catch(_ => false)
    canSendRelayServerCmd.value = !!res.data
  }
  const refreshCanSendRelayServerCmd = () => {
    checkCanSendRelayServerCmd()
  }
  onMounted(refreshCanSendRelayServerCmd)

  const rs = ref(null)
  const handleAlwaysUseRelaySuccess = () => {
    rs.value.save()
  }

  const canSendCmd = (target) => {
    if (target === ID_TARGET) return canSendIdServerCmd.value
    if (target === RELAY_TARGET) return canSendRelayServerCmd.value
    return false
  }

  const listRes = reactive({ list: [], total: 0, loading: false })
  const listQuery = reactive({ page: 1, page_size: 10 })
  const getList = async () => {
    listRes.loading = true
    const res = await list(listQuery).catch(_ => false)
    listRes.loading = false
    if (res) {
      listRes.list = res.data.list
      listRes.total = res.data.total
    }
  }
  const handlerQuery = () => {
    if (listQuery.page === 1) getList()
    else listQuery.page = 1
  }
  onMounted(getList)

  const del = (row) => {
    Modal.confirm({
      title: T('Confirm?'),
      icon: h(ExclamationCircleOutlined),
      content: T('Confirm?', { param: T('Delete') }),
      okText: T('Confirm'),
      cancelText: T('Cancel'),
      onOk: async () => {
        const res = await remove({ id: row.id }).catch(_ => false)
        if (res) {
          message.success(T('OperationSuccess'))
          getList()
        }
      }
    });
  }

  const formData = reactive({ id: 0, cmd: '', alias: '', option: '', target: '', explain: '' })
  const formVisible = ref(false)
  const toAdd = () => {
    formVisible.value = true
    formData.cmd = ''
    formData.alias = ''
    formData.option = ''
    formData.explain = ''
  }
  const toUpdate = (row) => {
    formVisible.value = true
    formData.id = row.id
    formData.cmd = row.cmd
    formData.alias = row.alias
    formData.option = row.option
    formData.target = row.target
    formData.explain = row.explain
  }
  const submit = () => {
    if (!formData.cmd) {
      message.error(T('ParamRequired', { param: 'cmd' }))
      return
    }
    const api = formData.id ? update : create
    api(formData).then(res => {
      message.success(T('OperationSuccess'))
      formVisible.value = false
      getList()
    })
  }

  const showCmdForm = ref(false)
  const customCmd = reactive({ cmd: '', option: '', target: '', res: '', example: '' })
  const showCmd = (row) => {
    showCmdForm.value = true
    customCmd.cmd = row.cmd
    customCmd.option = ''
    customCmd.res = ''
    customCmd.target = row.target
    customCmd.example = `${row.cmd} ${row.option}`
  }
  const submitCmd = () => {
    sendCmd(customCmd).then(res => {
      console.log(res)
      customCmd.res = res.data
      message.success(T('OperationSuccess'))
    })
  }
</script>

<style scoped lang="scss">
.simple-card {
  min-width: 300px;
  margin: 10px;
  min-height: 300px;
}
</style>
