<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery" class="list-query-form">
        <a-form-item label="ID">
          <a-input v-model:value="listQuery.id" clearable/>
        </a-form-item>
        <a-form-item :label="T('Hostname')">
          <a-input v-model:value="listQuery.hostname" clearable/>
        </a-form-item>
        <a-form-item :label="T('LastOnlineTime')">
          <a-select v-model:value="listQuery.time_ago" clearable style="width: 180px">
            <a-select-option
                v-for="item in timeFilters"
                :key="item.value"
                :value="item.value"
                :disabled="item.value === 0"
            >{{ item.text }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" @click="toExport" style="margin-left: 8px;">{{ T('Export') }}</a-button>
          <a-button type="primary" @click="toBatchAddToAB" style="margin-left: 8px;">{{ T('BatchAddToAB') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered size="small" :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'id'">
            <span>{{ record.id }} <CopyOutlined @click="handleClipboard(record.id, $event)" /></span>
          </template>
          <template v-if="column.key === 'last_online_time'">
            <div class="last_oline_time">
              <span> {{ record.last_online_time ? timeAgo(record.last_online_time * 1000) : '-' }}</span>
              <span class="dot" :class="{red: timeDis(record.last_online_time) >= 60, green: timeDis(record.last_online_time) < 60}"></span>
            </div>
          </template>
          <template v-if="column.key === 'actions'">
            <a-button type="primary" size="small" @click="connectByClient(record.id)">{{ T('Link') }}</a-button>
            <a-button v-if="appStore.setting.appConfig.web_client" type="primary" size="small" @click="toWebClientLink(record)" style="margin-left: 8px;">Web Client</a-button>
            <a-button type="primary" size="small" @click="toAddressBook(record)" style="margin-left: 8px;">{{ T('AddToAddressBook') }}</a-button>
            <a-button size="small" @click="toView(record)" style="margin-left: 8px;">{{ T('View') }}</a-button>
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

    <a-modal v-model:open="formVisible" :title="T('Information')" :footer="null">
      <a-form class="dialog-form" :model="formData" layout="vertical">
        <a-form-item label="ID"><a-input v-model:value="formData.id" disabled /></a-form-item>
        <a-form-item :label="T('Username')"><a-input v-model:value="formData.username" disabled /></a-form-item>
        <a-form-item :label="T('Hostname')"><a-input v-model:value="formData.hostname" disabled /></a-form-item>
        <a-form-item label="CPU"><a-input v-model:value="formData.cpu" disabled /></a-form-item>
        <a-form-item :label="T('Memory')"><a-input v-model:value="formData.memory" disabled /></a-form-item>
        <a-form-item :label="T('Os')"><a-input v-model:value="formData.os" disabled /></a-form-item>
        <a-form-item :label="T('Uuid')"><a-input v-model:value="formData.uuid" disabled /></a-form-item>
        <a-form-item :label="T('Version')"><a-input v-model:value="formData.version" disabled /></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="ABFormVisible" :title="T('Create')" @ok="ABSubmit" @cancel="ABFormVisible = false">
      <a-form class="dialog-form" :model="ABFormData" layout="vertical">
        <a-form-item :label="T('AddressBookName')" required><a-select v-model:value="ABFormData.collection_id" @change="changeCollectionForUpdate"><a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option><a-select-option v-for="c in collectionListResForUpdate.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option></a-select></a-form-item>
        <a-form-item label="ID" required><a-input v-model:value="ABFormData.id" /></a-form-item>
        <a-form-item :label="T('Username')"><a-input v-model:value="ABFormData.username" /></a-form-item>
        <a-form-item :label="T('Alias')"><a-input v-model:value="ABFormData.alias" /></a-form-item>
        <a-form-item :label="T('Hostname')"><a-input v-model:value="ABFormData.hostname" /></a-form-item>
        <a-form-item :label="T('Platform')"><a-select v-model:value="ABFormData.platform"><a-select-option v-for="item in ABPlatformList" :key="item.value" :value="item.value">{{ item.label }}</a-select-option></a-select></a-form-item>
        <a-form-item :label="T('Tags')"><a-select v-model:value="ABFormData.tags" mode="multiple"><a-select-option v-for="item in tagListRes.list" :key="item.name" :value="item.name">{{ item.name }}</a-select-option></a-select></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="batchABFormVisible" :title="T('Create')" @ok="submitBatchAddToAB" @cancel="batchABFormVisible = false">
      <a-form class="dialog-form" :model="batchABFormData" layout="vertical">
        <a-form-item :label="T('AddressBookName')" required><a-select v-model:value="batchABFormData.collection_id" @change="changeCollectionForBatchCreateAB"><a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option><a-select-option v-for="c in collectionListResForUpdate.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option></a-select></a-form-item>
        <a-form-item :label="T('Tags')"><a-select v-model:value="batchABFormData.tags" mode="multiple"><a-select-option v-for="item in tagListRes.list" :key="item.name" :value="item.name">{{ item.name }}</a-select-option></a-select></a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
  import { computed, onActivated, onMounted, reactive, ref, watch } from 'vue'
  import { list } from '@/api/my/peer'
  import { message } from 'ant-design-vue'
  import { toWebClientLink } from '@/utils/webclient'
  import { T } from '@/utils/i18n'
  import { timeAgo } from '@/utils/time'
  import { jsonToCsv, downBlob } from '@/utils/file'
  import { useRepositories as useABRepositories } from '@/views/address_book/index'
  import { useAppStore } from '@/store/app'
  import { connectByClient } from '@/utils/peer'
  import { handleClipboard } from '@/utils/clipboard'
  import { batchCreateFromPeers } from '@/api/my/address_book'

  const appStore = useAppStore()
  const listRes = reactive({
    list: [], total: 0, loading: false,
  })
  const listQuery = reactive({
    page: 1,
    page_size: 10,
    time_ago: null,
    id: '',
    hostname: '',
  })

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center', width: 150 },
    { title: 'CPU', dataIndex: 'cpu', key: 'cpu', align: 'center', width: 100, ellipsis: true },
    { title: T('Hostname'), dataIndex: 'hostname', key: 'hostname', align: 'center', width: 120 },
    { title: T('Memory'), dataIndex: 'memory', key: 'memory', align: 'center', width: 120 },
    { title: T('Os'), dataIndex: 'os', key: 'os', align: 'center', width: 120, ellipsis: true },
    { title: T('LastOnlineTime'), dataIndex: 'last_online_time', key: 'last_online_time', align: 'center', minWidth: 120 },
    { title: T('LastOnlineIp'), dataIndex: 'last_online_ip', key: 'last_online_ip', align: 'center', minWidth: 120 },
    { title: T('Username'), dataIndex: 'username', key: 'username', align: 'center', width: 120 },
    { title: T('Uuid'), dataIndex: 'uuid', key: 'uuid', align: 'center', width: 120, ellipsis: true },
    { title: T('Version'), dataIndex: 'version', key: 'version', align: 'center', width: 80 },
    { title: T('Alias'), dataIndex: 'alias', key: 'alias', align: 'center', width: 80 },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center', width: 150 },
    { title: T('UpdatedAt'), dataIndex: 'updated_at', key: 'updated_at', align: 'center', width: 150 },
    { title: T('Actions'), key: 'actions', align: 'center', width: 500, fixed: 'right' },
  ]);

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
    if (listQuery.page === 1) {
      getList()
    } else {
      listQuery.page = 1
    }
  }

  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, getList)

  const formVisible = ref(false)
  const formData = reactive({
    row_id: 0, cpu: '', hostname: '', id: '', memory: '', os: '', username: '', uuid: '', version: '',
  })

  const toView = (row) => {
    formVisible.value = true
    Object.keys(formData).forEach(key => {
      formData[key] = row[key]
    })
  }

  const timeDis = (time) => {
    let now = new Date().getTime()
    let after = new Date(time * 1000).getTime()
    return (now - after) / 1000
  }

  const timeFilters = computed(() => [
    { text: T('MinutesLess', { param: 1 }, 1), value: -60 },
    { text: T('HoursLess', { param: 1 }, 1), value: -3600 },
    { text: T('DaysLess', { param: 1 }, 1), value: -86400 },
    { text: '---------', value: 0 },
    { text: T('MinutesAgo', { param: 1 }, 1), value: 60 },
    { text: T('HoursAgo', { param: 1 }, 1), value: 3600 },
    { text: T('DaysAgo', { param: 1 }, 1), value: 86400 },
    { text: T('MonthsAgo', { param: 1 }, 1), value: 2592000 },
  ])

  const toExport = async () => {
    const q = { ...listQuery }
    q.page_size = 10000
    q.page = 1
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

  const {
    platformList: ABPlatformList,
    formVisible: ABFormVisible,
    formData: ABFormData,
    collectionListResForUpdate,
    getCollectionListForUpdate,
    tagListRes,
    changeCollectionForUpdate,
    submit: ABSubmit,
    fromPeer,
  } = useABRepositories('my')
  onMounted(getCollectionListForUpdate)
  const toAddressBook = (peer) => {
    fromPeer(peer)
    ABFormVisible.value = true
  }

  const selectedRowKeys = ref([]);
  const onSelectChange = (keys) => {
    selectedRowKeys.value = keys;
  };
  
  const batchABFormVisible = ref(false)
  const toBatchAddToAB = () => {
    if (selectedRowKeys.value.length === 0) {
      message.warning(T('PleaseSelectData'))
      return false
    }
    batchABFormVisible.value = true
  }
  const batchABFormData = ref({
    collection_id: 0,
    tags: [],
    peer_ids: [],
  })
  const changeCollectionForBatchCreateAB = (val) => {
    batchABFormData.value.tags = []
    changeCollectionForUpdate(val)
  }
  const submitBatchAddToAB = async () => {
    batchABFormData.value.peer_ids = selectedRowKeys.value
    if (!batchABFormData.value.peer_ids.length) {
      message.warning(T('PleaseSelectData'))
      return false
    }

    const res = await batchCreateFromPeers(batchABFormData.value).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      batchABFormVisible.value = false
      selectedRowKeys.value = []
    }
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
.last_oline_time {
  display: flex;
  justify-content: center;
  align-items: center;
}

.dot {
  width: 6px;
  height: 6px;
  display: block;
  border-radius: 50%;
  margin-left: 10px;

  &.red {
    background-color: red;
  }

  &.green {
    background-color: green;
  }
}
</style>