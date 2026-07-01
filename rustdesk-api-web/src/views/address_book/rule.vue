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
          <template v-if="column.key === 'rule'">
            {{ rules.find(r => r.value === record.rule)?.label }}
          </template>
          <template v-if="column.key === 'type'">
            {{ types.find(t => t.value === record.type)?.label }}
          </template>
          <template v-if="column.key === 'to_id'">
            <div v-if="record.type === TYPE_U">{{ users.find(u => u.id === record.to_id)?.username }}</div>
            <div v-else-if="record.type === TYPE_G">{{ groups.find(g => g.id === record.to_id)?.name }}</div>
          </template>
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
    <a-modal v-model:open="formVisible" :title="!formData.id ? T('Create') : T('Update')" @ok="submit" @cancel="formVisible = false" :mask-closable="false">
      <a-form class="dialog-form" :model="formData" layout="vertical" style="margin-top: 20px;">
        <a-form-item :label="T('AddressBookName')">
          {{ props.collection.name }}
        </a-form-item>
        <a-form-item :label="T('Rule')" name="rule" :rules="[{ required: true }]">
          <a-radio-group v-model:value="formData.rule">
            <a-radio v-for="item in rules" :key="item.value" :value="item.value">{{ item.label }}</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item :label="T('Type')" name="type" :rules="[{ required: true }]">
          <a-radio-group v-model:value="formData.type">
            <a-radio v-for="item in types" :key="item.value" :value="parseInt(item.value)">{{ item.label }}</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item :label="T('ShareTo')" name="g_id" :rules="[{ required: true }]">
          <a-input-group compact>
            <a-select v-model:value="formData.g_id" @change="changeGId" style="width: 50%;">
              <a-select-option v-for="item in groups" :key="item.id" :value="item.id">{{ item.name }}</a-select-option>
            </a-select>
            <a-select v-model:value="formData.u_id" v-if="formData.type === TYPE_U" style="width: 50%;">
              <a-select-option v-for="item in users.filter(u => u.group_id === formData.g_id)" :key="item.id" :value="item.id">{{ item.username }}</a-select-option>
            </a-select>
          </a-input-group>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
  import { T } from '@/utils/i18n'
  import { useRepositories } from '@/views/address_book/rule'
  import { onMounted, watch } from 'vue'

  const props = defineProps({
    collection: {
      type: Object,
      required: true,
    },
    is_my: {
      type: Number,
      default: 0,
    },
  })
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
    rules,
    types,
    groups,
    users,
    getGroupUsers,
    TYPE_G,
    TYPE_U,
    changeGId,
  } = useRepositories(props.is_my ? 'my' : 'admin')

  const columns = [
    { title: T('Rule'), key: 'rule', align: 'center' },
    { title: T('Type'), key: 'type', align: 'center' },
    { title: T('ShareTo'), key: 'to_id', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center', width: 300 },
  ];

  formData.collection_id = props.collection.id
  formData.user_id = props.collection.user_id
  listQuery.collection_id = props.collection.id

  onMounted(getGroupUsers)
  onMounted(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)
</script>

<style scoped lang="scss">
</style>