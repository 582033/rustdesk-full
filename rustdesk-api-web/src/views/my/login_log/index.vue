<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline">
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" danger @click="toBatchDelete" style="margin-left: 8px;">{{ T('BatchDelete') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'peer_id'">
            {{ record.device_id ? record.device_id : record.peer?.id }}
          </template>
          <template v-if="column.key === 'actions'">
            <a-button type="primary" danger size="small" @click="del(record)">{{ T('Delete') }}</a-button>
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
  import { useRepositories } from '@/views/login/log.js'
  import { T } from '@/utils/i18n'

  const {
    listRes, listQuery, getList, handlerQuery, del, batchdel,
  } = useRepositories('my')

  const columns = computed(() => [
    { title: 'Client', dataIndex: 'client', key: 'client', align: 'center' },
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
  const multipleSelection = ref([])
  const onSelectChange = (keys, selectedRows) => {
    selectedRowKeys.value = keys;
    multipleSelection.value = selectedRows;
  };

  const toBatchDelete = () => {
    if (multipleSelection.value.length === 0) {
      return
    }
    batchdel(multipleSelection.value)
  }
</script>

<style scoped lang="scss">
</style>