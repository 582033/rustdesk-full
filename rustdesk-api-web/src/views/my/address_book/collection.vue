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
      <a-alert :message="T('MyAddressBookTips')" type="error" banner style="margin-bottom: 10px" />
      <a-table :data-source="list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'actions'">
            <template v-if="record.id > 0">
              <a-button type="primary" size="small" @click="showRules(record)">{{ T('ShareRules') }}</a-button>
              <a-button size="small" @click="toEdit(record)" style="margin-left: 8px;">{{ T('Edit') }}</a-button>
              <a-button type="primary" danger size="small" @click="del(record)" style="margin-left: 8px;">{{ T('Delete') }}</a-button>
            </template>
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

    <a-modal v-model:open="rulesVisible" :title="T('ShareRules')" :footer="null" :destroy-on-close="true" width="80%">
      <Rule :collection="clickRow" :is_my="1"></Rule>
    </a-modal>
  </div>
</template>

<script setup>
  import { T } from '@/utils/i18n'
  import { computed, ref } from 'vue'
  import { useRepositories } from '@/views/address_book/collection'
  import { onMounted, watch } from 'vue'
  import Rule from '@/views/address_book/rule.vue'

  const {
    listRes,
    listQuery,
    getList,
    handlerQuery,
    del,
    formVisible,
    formData,
    toEdit,
    toAdd,
    submit,
  } = useRepositories('my')

  const columns = [
    { title: T('Name'), dataIndex: 'name', key: 'name', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center', width: 600 },
  ];

  onMounted(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)

  const list = computed(() => {
    if (listQuery.page > 1 || listRes.list.some(item => item.id === 0)) {
      return listRes.list
    } else {
      return [
        { id: 0, name: T('MyAddressBook'), created_at: '-' },
        ...listRes.list,
      ]
    }
  })

  const clickRow = ref({})
  const rulesVisible = ref(false)
  const showRules = (row) => {
    clickRow.value = row
    rulesVisible.value = true
  }
</script>

<style scoped lang="scss">
</style>