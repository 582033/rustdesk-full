<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline">
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'actions'">
            <a-button size="small" @click="toEdit(record)">{{ T('Edit') }}</a-button>
            <a-button type="primary" danger size="small" @click="del(record)" style="margin-left: 8px;">{{ T('Delete') }}</a-button>
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
    <a-modal v-model:open="formVisible" :title="!formData.id ? T('Create') : T('Update')" @ok="submit" @cancel="formVisible = false">
      <a-form class="dialog-form" :model="formData" layout="vertical" style="margin-top: 20px;">
        <a-form-item :label="T('Name')" name="name" :rules="[{ required: true }]">
          <a-input v-model:value="formData.name" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
  import { onMounted, reactive, watch, ref, onActivated, computed, h } from 'vue'
  import { list, create, update, remove } from '@/api/device_group'
  import { message, Modal } from 'ant-design-vue'
  import { ExclamationCircleOutlined } from '@ant-design/icons-vue'
  import { T } from '@/utils/i18n'

  const listRes = reactive({ list: [], total: 0, loading: false })
  const listQuery = reactive({ page: 1, page_size: 10 })

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center' },
    { title: T('Name'), dataIndex: 'name', key: 'name', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: T('UpdatedAt'), dataIndex: 'updated_at', key: 'updated_at', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center' },
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
        const res = await remove({ id: row.id }).catch(_ => false)
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
  watch(() => listQuery.page_size, handlerQuery)

  const formVisible = ref(false)
  const formData = reactive({ id: 0, name: '' })

  const toEdit = (row) => {
    formVisible.value = true
    formData.id = row.id
    formData.name = row.name
  }
  const toAdd = () => {
    formVisible.value = true
    formData.id = 0
    formData.name = ''
  }
  const submit = async () => {
    const api = formData.id ? update : create
    const res = await api(formData).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      formVisible.value = false
      getList()
    }
  }
</script>

<style scoped lang="scss">
</style>