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
          <template v-if="column.key === 'expire'">
            <a-tag :color="expired(record) ? 'default' : 'success'">{{ record.expire ? record.expire : T('Forever') }}</a-tag>
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
  import { onActivated, onMounted, watch, computed, ref } from 'vue'
  import { T } from '@/utils/i18n'
  import { useRepositories } from '@/views/share_record'

  const {
    listRes, listQuery, getList, handlerQuery, del,
    multipleSelection, toBatchDelete, expired,
  } = useRepositories('my')

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center', width: 100 },
    { title: T('Peer'), dataIndex: 'peer_id', key: 'peer_id', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: `${T('ExpireTime')} (${T('Second')})`, key: 'expire', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center', width: 400 },
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
</script>

<style scoped lang="scss">
</style>