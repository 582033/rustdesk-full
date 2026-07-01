<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery">
        <a-form-item :label="T('AddressBookName')">
          <a-select v-model:value="listQuery.collection_id" clearable style="width: 180px;">
            <a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option>
            <a-select-option v-for="c in collectionListRes.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'collection_id'">
            <span v-if="record.collection_id === 0">{{ T('MyAddressBook') }}</span>
            <span v-else>{{ collectionListRes.list.find(c => c.id === record.collection_id)?.name }}</span>
          </template>
          <template v-if="column.key === 'color'">
            <div class="colors">
              <div class="colorbox">
                <div :style="{ backgroundColor: record.color }" class="dot"></div>
              </div>
            </div>
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
    <a-modal v-model:open="formVisible" :title="!formData.id ? T('Create') : T('Update')" @ok="submit" @cancel="formVisible = false">
      <a-form class="dialog-form" :model="formData" layout="vertical" style="margin-top: 20px;">
        <a-form-item :label="T('AddressBookName')">
          <a-select v-model:value="formData.collection_id" clearable>
            <a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option>
            <a-select-option v-for="c in collectionListResForUpdate.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="T('Name')" name="name" :rules="[{ required: true }]">
          <a-input v-model:value="formData.name" />
        </a-form-item>
        <a-form-item :label="T('Color')" name="color" :rules="[{ required: true }]">
          <a-input v-model:value="formData.color" />
          <div class="colors">
            <div class="colorbox">
              <div :style="{ backgroundColor: formData.color }" class="dot"></div>
            </div>
          </div>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
  import { onMounted, watch, onActivated, computed } from 'vue'
  import { useRepositories } from '@/views/tag'
  import { T } from '@/utils/i18n'

  const {
    listRes, listQuery, getList, handlerQuery, del,
    formVisible, formData, toEdit, toAdd, submit,
    collectionListRes, getCollectionList,
    collectionListResForUpdate, getCollectionListForUpdate,
  } = useRepositories('my')

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center' },
    { title: T('AddressBook'), key: 'collection_id', align: 'center', width: 150 },
    { title: T('Name'), dataIndex: 'name', key: 'name', align: 'center' },
    { title: T('Color'), key: 'color', align: 'center' },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center' },
    { title: T('UpdatedAt'), dataIndex: 'updated_at', key: 'updated_at', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center' },
  ]);

  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)

  onMounted(getCollectionList)
  onMounted(getCollectionListForUpdate)
</script>

<style scoped lang="scss">
.colors {
  display: flex;
  align-items: center;
  margin-top: 10px;

  .colorbox {
    width: 50px;
    height: 30px;
    border: 1px solid #d9d9d9;
    display: flex;
    justify-content: center;
    align-items: center;

    .dot {
      width: 20px;
      height: 20px;
      display: block;
      border-radius: 50%;
    }
  }
}
</style>