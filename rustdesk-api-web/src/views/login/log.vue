<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery" class="list-query-form">
        <a-form-item :label="T('User')">
          <a-select v-model:value="listQuery.user_id" clearable style="width: 180px;">
            <a-select-option
                v-for="item in allUsers"
                :key="item.id"
                :label="item.username"
                :value="item.id"
            >{{ item.username }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" danger @click="toBatchDelete" style="margin-left: 8px;">{{ T('BatchDelete') }}</a-button>
          <a-button type="primary" @click="toExport" style="margin-left: 8px;">{{ T('Export') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'owner'">
            <span v-if="record.user_id"> <a-tag>{{ allUsers?.find(u => u.id === record.user_id)?.username }}</a-tag> </span>
          </template>
          <template v-if="column.key === 'peer_id'">
            {{ record.device_id ? record.device_id : record.peer?.id }}
          </template>
          <template v-if="column.key === 'actions'">
            <div class="actions-cell">
              <a-button type="primary" danger size="small" @click="del(record)">{{ T('Delete') }}</a-button>
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
  </div>
</template>

<script setup>
  import { onActivated, onMounted, ref, watch, computed } from 'vue'
  import { loadAllUsers } from '@/global'
  import { useRepositories } from '@/views/login/log.js'
  import { T } from '@/utils/i18n'
  import { downBlob, jsonToCsv } from '@/utils/file'

  const { allUsers, getAllUsers } = loadAllUsers()
  getAllUsers()

  const {
    listRes, listQuery, getList, handlerQuery, del, batchdel, toExport,
  } = useRepositories('admin')

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center', width: 100 },
    { title: 'Client', dataIndex: 'client', key: 'client', align: 'center', width: 120 },
    { title: T('Owner'), key: 'owner', align: 'center', width: 120 },
    { title: T('Peer'), key: 'peer_id', align: 'center' },
    { title: 'UUID', dataIndex: 'uuid', key: 'uuid', align: 'center', ellipsis: true },
    { title: 'IP', dataIndex: 'ip', key: 'ip', align: 'center' },
    { title: 'Type', dataIndex: 'type', key: 'type', align: 'center' },
    { title: 'Platform/UA', dataIndex: 'platform', key: 'platform', align: 'center', ellipsis: true },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center' },
  ]);

  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)

  const selectedRowKeys = ref([]);
  const onSelectChange = (keys, selectedRows) => {
    selectedRowKeys.value = keys;
    multipleSelection.value = selectedRows;
  };

  const multipleSelection = ref([])
  const toBatchDelete = () => {
    if (multipleSelection.value.length === 0) {
      return
    }
    batchdel(multipleSelection.value)
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
.actions-cell {
  display: flex;
  justify-content: center;
  gap: 8px;
}
</style>