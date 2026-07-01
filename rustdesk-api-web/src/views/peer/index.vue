<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery" class="list-query-form">
        <a-form-item label="ID"><a-input v-model:value="listQuery.id" clearable /></a-form-item>
        <a-form-item :label="T('Hostname')"><a-input v-model:value="listQuery.hostname" clearable /></a-form-item>
        <a-form-item :label="T('LastOnlineTime')"><a-select v-model:value="listQuery.time_ago" clearable style="width: 180px;"><a-select-option v-for="item in timeFilters" :key="item.value" :value="item.value" :disabled="item.value === 0">{{ item.text }}</a-select-option></a-select></a-form-item>
        <a-form-item :label="T('Username')"><a-input v-model:value="listQuery.username" clearable /></a-form-item>
        <a-form-item label="IP"><a-input v-model:value="listQuery.ip" clearable /></a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
          <a-button type="primary" @click="toExport" style="margin-left: 8px;">{{ T('Export') }}</a-button>
          <a-popover v-model:open="showImport" placement="bottom" title="Import" trigger="click">
            <template #content>
              <a-upload-dragger accept=".csv" :before-upload="parseCsv" :showUploadList="false">
                <p class="ant-upload-drag-icon"><InboxOutlined /></p>
                <p class="ant-upload-text">{{ T('Drop file here or click to upload') }}</p>
                <p class="ant-upload-hint">{{ T('Please upload csv file') }}<br/>{{ T('Columns') }}: <span style="font-weight: bold;font-size: 15px">id,cpu,hostname,memory,os,username,uuid,version,group_id</span><br/>{{ T('You can reference export file') }}</p>
              </a-upload-dragger>
            </template>
            <a-button type="primary" style="margin-left: 8px;">{{ T('Import') }}</a-button>
          </a-popover>
          <a-button type="primary" danger @click="toBatchDelete" style="margin-left: 8px;">{{ T('BatchDelete') }}</a-button>
          <a-button type="primary" @click="toBatchAddToAB" style="margin-left: 8px;">{{ T('BatchAddToAB') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <div style="text-align: right; margin-bottom: 10px;">
        <a-button @click="showColumnSetting"><SettingOutlined /></a-button>
      </div>
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="tableColumns" bordered size="small" :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }" rowKey="row_id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'id'"><span>{{ record.id }} <CopyOutlined @click="handleClipboard(record.id, $event)" /></span></template>
          <template v-if="column.key === 'last_online_time'"><div class="last_oline_time"><span> {{ record.last_online_time ? timeAgo(record.last_online_time * 1000) : '-' }}</span> <span class="dot" :class="{red: timeDis(record.last_online_time) >= 60, green: timeDis(record.last_online_time) < 60}"></span></div></template>
          <template v-if="column.key === 'group_id'"><span v-if="record.group_id"> <a-tag>{{ groupListRes.list?.find(g => g.id === record.group_id)?.name }} </a-tag> </span><span v-else> - </span></template>
          <template v-if="column.key === 'actions'">
            <a-button type="primary" size="small" @click="connectByClient(record.id)">{{ T('Link') }}</a-button>
            <a-button v-if="appStore.setting.appConfig.web_client" type="primary" size="small" @click="toWebClientLink(record)" style="margin-left: 8px;">Web Client</a-button>
            <a-button type="primary" size="small" @click="toAddressBook(record)" style="margin-left: 8px;">{{ T('AddToAddressBook') }}</a-button>
            <a-button size="small" @click="toEdit(record)" style="margin-left: 8px;">{{ T('Edit') }}</a-button>
            <a-button type="primary" danger size="small" @click="del(record)" style="margin-left: 8px;">{{ T('Delete') }}</a-button>
          </template>
        </template>
      </a-table>
      <a-pagination style="margin-top: 12px; text-align: right;" v-model:current="listQuery.page" v-model:pageSize="listQuery.page_size" :total="listRes.total" show-size-changer show-quick-jumper :show-total="total => `${T('Total')} ${total} ${T('Items')}`" />
    </a-card>

    <a-modal v-model:open="formVisible" :title="!formData.row_id ? T('Create') : T('Update')" @ok="submit" @cancel="formVisible = false">
      <a-form class="dialog-form" :model="formData" layout="vertical" style="margin-top: 20px;">
        <a-form-item label="ID" name="id" :rules="[{ required: true }]"><a-input v-model:value="formData.id" /></a-form-item>
        <a-form-item :label="T('Group')"><a-select v-model:value="formData.group_id"><a-select-option v-for="item in groupListRes.list" :key="item.id" :value="item.id">{{ item.name }}</a-select-option></a-select></a-form-item>
        <a-form-item :label="T('Username')"><a-input v-model:value="formData.username" /></a-form-item>
        <a-form-item :label="T('Hostname')"><a-input v-model:value="formData.hostname" /></a-form-item>
        <a-form-item label="CPU"><a-input v-model:value="formData.cpu" /></a-form-item>
        <a-form-item :label="T('Memory')"><a-input v-model:value="formData.memory" /></a-form-item>
        <a-form-item :label="T('Os')"><a-input v-model:value="formData.os" /></a-form-item>
        <a-form-item :label="T('Uuid')"><a-input v-model:value="formData.uuid" /></a-form-item>
        <a-form-item :label="T('Version')"><a-input v-model:value="formData.version" /></a-form-item>
        <a-form-item :label="T('Alias')"><a-input v-model:value="formData.alias" /></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="ABFormVisible" :title="T('Create')" :footer="null" :destroy-on-close="true">
      <createABForm :peer="clickRow" @success="ABFormVisible = false" @cancel="ABFormVisible = false" />
    </a-modal>

    <a-modal v-model:open="batchABFormVisible" :title="T('Create')" @ok="submitBatchAddToAB" @cancel="batchABFormVisible = false">
      <a-form class="dialog-form" :model="batchABFormData" layout="vertical" style="margin-top: 20px;">
        <a-form-item :label="T('Owner')" name="user_id" :rules="[{ required: true }]"><a-select v-model:value="batchABFormData.user_id" @change="changeUserForBatchCreateAB"><a-select-option v-for="item in allUsers" :key="item.id" :value="item.id">{{ item.username }}</a-select-option></a-select></a-form-item>
        <a-form-item :label="T('AddressBookName')" name="collection_id" :rules="[{ required: true }]"><a-select v-model:value="batchABFormData.collection_id" clearable><a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option><a-select-option v-for="c in collectionListResForBatchCreateAB.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option></a-select></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="columnSettingVisible" title="Column Setting" @ok="saveColumnSetting">
      <div v-for="(row, key) in visibleColumns" :key="key" style="margin-bottom: 10px; display: flex; align-items: center;">
        <div style="width: 200px;"><a-checkbox v-model:checked="row.visible">{{ T(row.label) }}</a-checkbox></div>
        <div @click="upColumn(key)" style="width: 100px; cursor: pointer;"><ArrowUpOutlined /></div>
        <div @click="downColumn(key)" style="width: 100px; cursor: pointer;"><ArrowDownOutlined /></div>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
  import { computed, onActivated, onMounted, reactive, ref, watch, h } from 'vue'
  import { batchRemove, create, list, remove, update } from '@/api/peer'
  import { list as groupList } from '@/api/device_group'
  import { message, Modal } from 'ant-design-vue'
  import { toWebClientLink } from '@/utils/webclient'
  import { T } from '@/utils/i18n'
  import { timeAgo } from '@/utils/time'
  import { jsonToCsv, downBlob } from '@/utils/file'
  import { loadAllUsers } from '@/global'
  import { useAppStore } from '@/store/app'
  import { connectByClient } from '@/utils/peer'
  import { handleClipboard } from '@/utils/clipboard'
  import { batchCreateFromPeers } from '@/api/address_book'
  import { useRepositories as useCollectionRepositories } from '@/views/address_book/collection'
  import createABForm from '@/views/peer/createABForm.vue'
  import { ExclamationCircleOutlined } from '@ant-design/icons-vue'

  const appStore = useAppStore()

  const groupListRes = reactive({ list: [], total: 0, loading: false })
  const groupListQuery = reactive({ page: 1, page_size: 999 })
  const getGroupList = async () => {
    groupListRes.loading = true
    const res = await groupList(groupListQuery).catch(_ => false)
    groupListRes.loading = false
    if (res) {
      groupListRes.list = res.data.list
      groupListRes.total = res.data.total
    }
  }
  onMounted(getGroupList)

  const listRes = reactive({ list: [], total: 0, loading: false })
  const listQuery = reactive({ page: 1, page_size: 10, time_ago: null, id: '', hostname: '', username: '', ip: '' })

  const tableColumns = computed(() => visibleColumns.value.filter(c => c.visible).map(c => ({
    title: T(c.label), dataIndex: c.name, key: c.name, align: 'center', ellipsis: true, ...c.props
  })).concat({ title: T('Actions'), key: 'actions', align: 'center', width: 500, fixed: 'right' }))

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

  const del = (row) => {
    Modal.confirm({
      title: T('Confirm?'),
      icon: h(ExclamationCircleOutlined),
      content: T('Confirm?', { param: T('Delete') }),
      okText: T('Confirm'),
      cancelText: T('Cancel'),
      onOk: async () => {
        const res = await remove({ row_id: row.row_id }).catch(_ => false)
        if (res) {
          message.success(T('OperationSuccess'))
          getList()
        }
      }
    });
  }
  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, getList)

  const formVisible = ref(false)
  const formData = reactive({ row_id: 0, group_id: null, cpu: '', hostname: '', id: '', memory: '', os: '', username: '', uuid: '', version: '' })

  const toEdit = (row) => {
    formVisible.value = true
    Object.keys(formData).forEach(key => { formData[key] = row[key] })
  }
  const toAdd = () => {
    formVisible.value = true
    Object.keys(formData).forEach(key => { formData[key] = '' })
    formData.row_id = 0
    formData.group_id = null
  }
  const submit = async () => {
    const api = formData.row_id ? update : create
    const res = await api(formData).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      formVisible.value = false
      getList()
    }
  }

  const timeDis = (time) => (new Date().getTime() - new Date(time * 1000).getTime()) / 1000
  const timeFilters = computed(() => [
    { text: T('MinutesLess', { param: 1 }, 1), value: -60 }, { text: T('HoursLess', { param: 1 }, 1), value: -3600 }, { text: T('DaysLess', { param: 1 }, 1), value: -86400 },
    { text: '---------', value: 0 },
    { text: T('MinutesAgo', { param: 1 }, 1), value: 60 }, { text: T('HoursAgo', { param: 1 }, 1), value: 3600 }, { text: T('DaysAgo', { param: 1 }, 1), value: 86400 }, { text: T('MonthsAgo', { param: 1 }, 1), value: 2592000 },
  ])

  const toExport = async () => {
    const q = { ...listQuery, page_size: 10000, page: 1 }
    const res = await list(q).catch(_ => false)
    if (res) {
      const data = res.data.list.map(item => {
        item.last_online_time = item.last_online_time ? new Date(item.last_online_time * 1000).toLocaleString() : '-'
        delete item.user_id
        delete item.user
        return item
      })
      const csv = jsonToCsv(data)
      downBlob(csv, 'peers.csv')
    }
  }

  const showImport = ref(false)
  const canKeys = ['id', 'cpu', 'hostname', 'memory', 'os', 'username', 'uuid', 'version', 'group_id']
  const parseCsv = (file) => {
    const reader = new FileReader()
    reader.onload = async (e) => {
      const data = e.target.result
      const rows = data.split('\n')
      const keys = rows[0].split(',')
      const values = rows.slice(1).map(row => {
        const obj = {}
        row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).forEach((v, i) => { obj[keys[i]] = v.trim().replace(/^"|"$/g, '') })
        return obj
      }).filter(item => item.id)
      values.forEach(item => {
        item.group_id = parseInt(item.group_id)
        Object.keys(item).forEach(key => { if (!canKeys.includes(key)) delete item[key] })
      })
      const pa = values.map(item => create(item))
      const res = await Promise.all(pa).catch(_ => false)
      if (res) {
        message.success(T('OperationSuccess'))
        getList()
        showImport.value = false
      }
    }
    reader.readAsText(file)
    return false
  }

  const ABFormVisible = ref(false)
  const clickRow = ref({})
  const toAddressBook = (row) => {
    clickRow.value = row
    ABFormVisible.value = true
  }

  const selectedRowKeys = ref([]);
  const multipleSelection = ref([])
  const onSelectChange = (keys, selectedRows) => {
    selectedRowKeys.value = keys;
    multipleSelection.value = selectedRows;
  };

  const toBatchDelete = () => {
    if (!multipleSelection.value.length) return message.warning(T('PleaseSelectData'))
    Modal.confirm({
      title: T('Confirm?'),
      icon: h(ExclamationCircleOutlined),
      content: T('Confirm?', { param: T('BatchDelete') }),
      okText: T('Confirm'),
      cancelText: T('Cancel'),
      onOk: async () => {
        const res = await batchRemove({ row_ids: multipleSelection.value.map(i => i.row_id) }).catch(_ => false)
        if (res) {
          message.success(T('OperationSuccess'))
          getList()
          selectedRowKeys.value = []
          multipleSelection.value = []
        }
      }
    });
  }

  const { allUsers, getAllUsers } = loadAllUsers()
  onMounted(getAllUsers)
  const { listRes: collectionListResForBatchCreateAB, listQuery: collectionListQueryForBatchCreateAB, getList: getCollectionListForBatchCreateAB } = useCollectionRepositories('admin')
  collectionListQueryForBatchCreateAB.page_size = 9999
  const changeUserForBatchCreateAB = (val) => {
    batchABFormData.value.collection_id = 0
    collectionListQueryForBatchCreateAB.user_id = val
    getCollectionListForBatchCreateAB()
  }
  const batchABFormVisible = ref(false)
  const toBatchAddToAB = () => {
    if (!multipleSelection.value.length) return message.warning(T('PleaseSelectData'))
    batchABFormVisible.value = true
  }
  const batchABFormData = ref({ collection_id: 0, tags: [], peer_ids: [], user_id: null })
  const submitBatchAddToAB = async () => {
    batchABFormData.value.peer_ids = multipleSelection.value.map(i => i.row_id)
    if (!batchABFormData.value.peer_ids.length) return message.warning(T('PleaseSelectData'))
    const res = await batchCreateFromPeers(batchABFormData.value).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      batchABFormVisible.value = false
    }
  }

  const columnSettingVisible = ref(false)
  const allColumns = ref([
    { name: 'id', visible: true, label: 'Id', props: { width: 150 } }, { name: 'cpu', visible: true, label: 'Cpu', props: { width: 100 } }, { name: 'hostname', visible: true, label: 'Hostname', props: { width: 120 } },
    { name: 'memory', visible: true, label: 'Memory', props: { width: 120 } }, { name: 'os', visible: true, label: 'Os', props: { width: 120 } }, { name: 'last_online_time', visible: true, label: 'LastOnlineTime', props: { minWidth: 120 } },
    { name: 'last_online_ip', visible: true, label: 'LastOnlineIp', props: { minWidth: 120 } }, { name: 'username', visible: true, label: 'Username', props: { width: 120 } }, { name: 'group_id', visible: true, label: 'Group', props: { width: 120 } },
    { name: 'uuid', visible: true, label: 'Uuid', props: { width: 120 } }, { name: 'version', visible: true, label: 'Version', props: { width: 80 } }, { name: 'alias', visible: true, label: 'Alias', props: { width: 80 } },
    { name: 'created_at', visible: true, label: 'CreatedAt', props: { width: 150 } }, { name: 'updated_at', visible: true, label: 'UpdatedAt', props: { width: 150 } },
  ])
  const visibleColumns = ref(JSON.parse(localStorage.getItem('peer_visible_columns')) || allColumns.value)
  const showColumnSetting = () => { columnSettingVisible.value = true }
  const saveColumnSetting = () => {
    localStorage.setItem('peer_visible_columns', JSON.stringify(visibleColumns.value))
    message.success(T('OperationSuccess'))
    columnSettingVisible.value = false
  }
  const upColumn = (index) => {
    if (index === 0) return
    const col = visibleColumns.value[index]
    visibleColumns.value.splice(index, 1)
    visibleColumns.value.splice(index - 1, 0, col)
  }
  const downColumn = (index) => {
    if (index === visibleColumns.value.length - 1) return
    const col = visibleColumns.value[index]
    visibleColumns.value.splice(index, 1)
    visibleColumns.value.splice(index + 1, 0, col)
  }
</script>

<style scoped lang="scss">
.list-query-form {
  display: flex;
  flex-wrap: wrap;
  .ant-form-item {
    margin-bottom: 12px;
  }
}
.last_oline_time { display: flex; justify-content: center; align-items: center; }
.dot { width: 6px; height: 6px; display: block; border-radius: 50%; margin-left: 10px; &.red { background-color: red; } &.green { background-color: green; } }
</style>