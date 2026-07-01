<template>
  <div class="container">
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery">
        <a-form-item :label="T('Peer')"><a-input v-model:value="listQuery.peer_id" clearable /></a-form-item>
        <a-form-item :label="T('FromPeer')"><a-input v-model:value="listQuery.from_peer" clearable /></a-form-item>
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
          <template v-if="column.key === 'created_at'">
            {{ formatTime(record.created_at) }}
          </template>
          <template v-if="column.key === 'close_time'">
            {{ formatTime(record.close_time) }}
          </template>
          <template v-if="column.key === 'type'">
            <a-tag v-if="record.type === 1" color="warning">{{ T('File') }}</a-tag>
            <a-tag v-else>{{ T('Common') }}</a-tag>
          </template>
          <template v-if="column.key === 'actions'">
            <a-button type="primary" danger size="small" @click="del(record)">{{ T('Delete') }}</a-button>
          </template>
        </template>
      </a-table>
    </a-card>
    <a-card class="list-page" :bordered="false">
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
  import { useRepositories } from '@/views/audit/reponsitories'
  import { T } from '@/utils/i18n'
  import { formatTime } from '@/utils/time'

  const {
    listRes, listQuery, getList, handlerQuery, del, batchdel, toExport,
  } = useRepositories()

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center', width: 100 },
    { title: T('Peer'), dataIndex: 'peer_id', key: 'peer_id', align: 'center', width: 120 },
    { title: T('FromPeer'), dataIndex: 'from_peer', key: 'from_peer', align: 'center', width: 120 },
    { title: T('FromName'), dataIndex: 'from_name', key: 'from_name', align: 'center', width: 120 },
    { title: T('Ip'), dataIndex: 'ip', key: 'ip', align: 'center', width: 120 },
    { title: T('Type'), key: 'type', align: 'center', width: 120 },
    { title: 'UUID', dataIndex: 'uuid', key: 'uuid', align: 'center', width: 120, ellipsis: true },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center', width: 200 },
    { title: T('CloseTime'), dataIndex: 'close_time', key: 'close_time', align: 'center', width: 200 },
    { title: T('Actions'), key: 'actions', align: 'center', width: 150 },
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
.container {
  height: 100%;
  display: flex;
  flex-direction: column;

  .list-query {
    margin-bottom: 12px;
  }

  .list-body {
    flex: 1;
    overflow: auto;
  }

  .list-page {
    margin-top: 12px;
  }
}
</style>