<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery">
        <a-form-item :label="T('Username')">
          <a-input v-model:value="listQuery.username" />
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
          <a-button type="primary" @click="toExport" style="margin-left: 8px;">{{ T('Export') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'group_id'">
            <span v-if="record.group_id"> <a-tag>{{ listRes.groups?.find(g => g.id === record.group_id)?.name }} </a-tag> </span>
            <span v-else> - </span>
          </template>
          <template v-if="column.key === 'status'">
            <a-switch :checked="record.status === ENABLE_STATUS" @change="checked => changeStatus(record, checked)" />
          </template>
          <template v-if="column.key === 'expire_at'">
            <span v-if="record.expire_at > 0" :style="record.expire_at <= now ? 'color:red' : ''">
              {{ formatTime(record.expire_at) }}
            </span>
            <span v-else>-</span>
          </template>
          <template v-if="column.key === 'actions'">
            <div class="actions-cell">
              <a-button size="small" @click="toEdit(record)">{{ T('Edit') }}</a-button>
              <a-button type="dashed" size="small" @click="copyCredentials(record)">{{ T('Copy') }}</a-button>
              <a-button type="dashed" size="small" @click="showExtendDialog(record)">{{ T('ExtendExpireTime') }}</a-button>
              <a-button type="dashed" danger size="small" @click="changePass(record)">{{ T('ResetPassword') }}</a-button>
              <a-button type="primary" danger size="small" @click="remove(record)">{{ T('Delete') }}</a-button>
            </div>
          </template>
        </template>
      </a-table>
      <a-pagination
          style="margin-top: 12px; text-align: right;"
          v-model:current="listQuery.page"
          v-model:pageSize="listQuery.page_size"
          :total="listRes.total"
          show-size-changer
          show-quick-jumper
          :show-total="total => `${T('Total')} ${total} ${T('Items')}`"
      />
    </a-card>

    <a-modal v-model:open="extendVisible" :title="T('ExtendExpireTime')" @ok="confirmExtend" :confirm-loading="extendLoading">
      <a-form layout="vertical">
        <a-form-item :label="T('Username')">
          <a-input :value="extendUser?.username" disabled />
        </a-form-item>
        <a-form-item label="当前过期时间">
          <a-input :value="extendUser?.expire_at > 0 ? formatTime(extendUser.expire_at) : '永不过期'" disabled />
        </a-form-item>
        <a-form-item label="延期语法" extra="支持语法: @1m(分钟), @1h(小时), @1d(天), @1M(月)，例如 @7d 表示延长7天">
          <a-input v-model:value="extendSyntax" placeholder="@7d" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
  import { handleClipboard } from '@/utils/clipboard'
  import { useRepositories, useDel, useToEditOrAdd, useChangePwd } from '@/views/user/composables'
  import { T } from '@/utils/i18n'
  import { DISABLE_STATUS, ENABLE_STATUS } from '@/utils/common_options'
  import { update, setExpireTime } from '@/api/user'
  import { message } from 'ant-design-vue'
  import { onMounted, watch, computed, ref } from 'vue'

  const {
    listRes, listQuery, handlerQuery, getList, getGroups, toExport,
  } = useRepositories()

  const now = Date.now() / 1000

  const formatTime = (ts) => {
    if (!ts) return '-'
    const d = new Date(ts * 1000)
    const pad = (n) => String(n).padStart(2, '0')
    return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
  }

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center' },
    { title: T('Username'), dataIndex: 'username', key: 'username', align: 'center' },
    { title: T('Email'), dataIndex: 'email', key: 'email', align: 'center' },
    { title: T('Nickname'), dataIndex: 'nickname', key: 'nickname', align: 'center' },
    { title: T('Group'), key: 'group_id', align: 'center' },
    { title: T('Status'), key: 'status', align: 'center' },
    { title: '过期时间', key: 'expire_at', align: 'center', width: 160 },
    { title: T('Remark'), dataIndex: 'remark', key: 'remark', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: T('UpdatedAt'), dataIndex: 'updated_at', key: 'updated_at', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center', width: 750 },
  ]);

  onMounted(getGroups)
  onMounted(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)

  const { toEdit, toAdd } = useToEditOrAdd()
  const { changePass } = useChangePwd()
  const { del } = useDel()
  const remove = async (row) => {
    const res = await del(row.id)
    if (res) {
      getList(listQuery)
    }
  }

  const copyCredentials = async (row) => {
    const username = row.username
    const password = btoa(username + '\n')
    const textToCopy = `您的用户名为 ${username} 密码为 ${password}`
    try {
      await handleClipboard(textToCopy)
      message.success('已成功复制到剪贴板')
    } catch (err) {
      message.error('复制失败，请稍后重试')
      console.error('Clipboard write failed: ', err)
    }
  }

  const changeStatus = async (row, checked) => {
    const newStatus = checked ? ENABLE_STATUS : DISABLE_STATUS;
    const res = await update({ ...row, status: newStatus }).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
    }
    // No matter success or fail, refresh the list to get the real status
    getList(listQuery)
  }

  const extendVisible = ref(false)
  const extendLoading = ref(false)
  const extendUser = ref(null)
  const extendSyntax = ref('')

  const showExtendDialog = (row) => {
    extendUser.value = row
    extendSyntax.value = ''
    extendVisible.value = true
  }

  const parseDuration = (syntax) => {
    const m = syntax.match(/^@(\d+)([smhdM])$/)
    if (!m) return null
    const num = parseInt(m[1])
    const unit = m[2]
    switch (unit) {
      case 's': return num
      case 'm': return num * 60
      case 'h': return num * 3600
      case 'd': return num * 86400
      case 'M': return num * 86400 * 30
      default: return null
    }
  }

  const confirmExtend = async () => {
    const seconds = parseDuration(extendSyntax.value.trim())
    if (!seconds) {
      message.error('语法错误，格式如 @7d（@数量+单位: m分钟 h小时 d天 M月）')
      return
    }
    extendLoading.value = true
    const user = extendUser.value
    const base = user.expire_at > Math.floor(Date.now() / 1000) ? user.expire_at : Math.floor(Date.now() / 1000)
    const newExpire = base + seconds
    const res = await setExpireTime({ user_id: user.id, expire_at: newExpire }).catch(_ => false)
    if (res && user.status !== ENABLE_STATUS && newExpire > Math.floor(Date.now() / 1000)) {
      await update({ ...user, expire_at: newExpire, status: ENABLE_STATUS }).catch(_ => false)
    }
    extendLoading.value = false
    if (res) {
      message.success(`已延期至 ${formatTime(newExpire)}`)
      extendVisible.value = false
      getList(listQuery)
    }
  }
</script>

<style scoped>
.actions-cell {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}
</style>