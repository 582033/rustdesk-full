<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery">
        <a-form-item :label="T('User')">
          <a-select v-model:value="listQuery.user_id" clearable style="width: 180px;">
            <a-select-option
                v-for="item in allUsers"
                :key="item.id"
                :value="item.id"
            >{{ item.username }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" danger @click="toBatchDelete" style="margin-left: 8px;">{{ T('BatchDelete') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'owner'">
            <span v-if="record.user_id"> <a-tag>{{ allUsers?.find(u => u.id === record.user_id)?.username }}</a-tag> </span>
          </template>
          <template v-if="column.key === 'token'">
            <span> {{ maskToken(record.token) }} </span>
          </template>
          <template v-if="column.key === 'expire_time'">
            <a-tag :color="expired(record) ? 'default' : 'success'">{{ record.expired_at ? new Date(record.expired_at * 1000).toLocaleString() : '-' }}</a-tag>
          </template>
          <template v-if="column.key === 'actions'">
            <a-button type="primary" danger size="small" @click="del(record)">{{ T('Logout') }}</a-button>
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
  import { useRepositories } from '@/views/user/token.js'
  import { T } from '@/utils/i18n'

  const { allUsers, getAllUsers } = loadAllUsers()
  getAllUsers()

  const {
    listRes, listQuery, getList, handlerQuery, del, batchDelete,
  } = useRepositories()

  const columns = computed(() => [
    { title: 'id', dataIndex: 'id', key: 'id', align: 'center', width: 100 },
    { title: T('Owner'), key: 'owner', align: 'center' },
    { title: T('Token'), key: 'token', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: T('ExpireTime'), key: 'expire_time', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center', width: 400 },
  ]);

  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)

  const maskToken = (token) => token.slice(0, 4) + '****' + token.slice(-4)
  const expired = (row) => new Date().getTime() > row.expired_at * 1000

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
    batchDelete(multipleSelection.value.map(v => v.id))
  }
</script>

<style scoped lang="scss">
</style>