<template>
  <div>
    <a-card class="list-query">
      <a-form layout="inline">
        <a-form-item :label="T('User')">
          <a-select v-model:value="listQuery.user_id" clearable style="width: 160px">
            <a-select-option
                v-for="item in allUsers"
                :key="item.id"
                :value="item.id"
            >{{ item.username }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button danger @click="toBatchDelete" style="margin-left: 8px;">{{ T('BatchDelete') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" style="margin-top: 16px;">
      <a-table
        :data-source="listRes.list"
        :loading="listRes.loading"
        bordered
        :row-key="record => record.id"
        :columns="columns"
        :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
        :pagination="false"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'user_id'">
            <span v-if="record.user_id"> <a-tag>{{ allUsers?.find(u => u.id === record.user_id)?.username }}</a-tag> </span>
          </template>
          <template v-if="column.dataIndex === 'expire'">
             <a-tag :color="expired(record)?'#808080':'#87d068'">{{ record.expire ? record.expire : T('Forever') }}</a-tag>
          </template>
          <template v-if="column.dataIndex === 'actions'">
            <a-button danger @click="del(record)">{{ T('Delete') }}</a-button>
          </template>
        </template>
      </a-table>
    </a-card>
    <a-card class="list-page" style="margin-top: 16px;">
      <a-pagination
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
  import { T } from '@/utils/i18n'
  import { useRepositories } from '@/views/share_record/index'

  const { allUsers, getAllUsers } = loadAllUsers()
  getAllUsers()

  const {
    listRes,
    listQuery,
    getList,
    handlerQuery,
    del,
    multipleSelection,
    toBatchDelete,
    expired,
  } = useRepositories('admin')

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', align: 'center', width: 100 },
    { title: T('User'), dataIndex: 'user_id', align: 'center', width: 120 },
    { title: T('Peer'), dataIndex: 'peer_id', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', align: 'center' },
    { title: `${T('ExpireTime')} (${T('Second')})`, dataIndex: 'expire', align: 'center' },
    { title: T('Actions'), dataIndex: 'actions', align: 'center', width: 400 },
  ])

  const selectedRowKeys = ref([]);

  const onSelectChange = (keys, selectedRows) => {
    selectedRowKeys.value = keys;
    multipleSelection.value = selectedRows;
  };

  watch(multipleSelection, () => {
    selectedRowKeys.value = multipleSelection.value.map(item => item.id);
  });


  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, getList)

</script>

<style scoped lang="scss">
.list-query .ant-select {
  width: 160px;
}
</style>
