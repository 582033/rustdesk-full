<template>
  <div>
    <a-card class="list-query" :bordered="false">
      <a-form layout="inline" :model="listQuery">
        <a-form-item :label="T('AddressBookName')">
          <a-select v-model:value="listQuery.collection_id" clearable style="width: 180px">
            <a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option>
            <a-select-option v-for="c in collectionListRes.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="T('Id')"><a-input v-model:value="listQuery.id" clearable /></a-form-item>
        <a-form-item :label="T('Username')"><a-input v-model:value="listQuery.username" clearable /></a-form-item>
        <a-form-item :label="T('Hostname')"><a-input v-model:value="listQuery.hostname" clearable /></a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
          <a-button type="primary" @click="showBatchEditTags" style="margin-left: 8px;">{{ T('BatchEditTags') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" :bordered="false">
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }" rowKey="row_id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'id'">
            <PlatformIcons :name="platformList.find(p => p.label === record.platform)?.icon" style="width: 20px; height: 20px; display: inline-block" color="var(--basicBlack)" />
            {{ record.id }}
            <CopyOutlined @click="handleClipboard(record.id, $event)" />
          </template>
          <template v-if="column.key === 'collection_id'">
            <span v-if="record.collection_id === 0">{{ T('MyAddressBook') }}</span>
            <span v-else>{{ collectionListRes.list.find(c => c.id === record.collection_id)?.name }}</span>
          </template>
          <template v-if="column.key === 'actions'">
            <a-button type="primary" size="small" @click="connectByClient(record.id)">{{ T('Link') }}</a-button>
            <a-button v-if="appStore.setting.appConfig.web_client" type="primary" size="small" @click="toWebClientLink(record)" style="margin-left: 8px;">Web Client</a-button>
            <a-button v-if="appStore.setting.appConfig.web_client" type="primary" size="small" @click="toShowShare(record)" style="margin-left: 8px;">{{ T('ShareByWebClient') }}</a-button>
            <a-button size="small" @click="toEdit(record)" style="margin-left: 8px;">{{ T('Edit') }}</a-button>
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

    <a-modal v-model:open="formVisible" :title="!formData.row_id ? T('Create') : T('Update')" @ok="submit" @cancel="formVisible = false">
      <a-form class="dialog-form" :model="formData" layout="vertical" style="margin-top: 20px;">
        <a-form-item :label="T('AddressBookName')" name="collection_id" :rules="[{ required: true }]"><a-select v-model:value="formData.collection_id" @change="changeCollectionForUpdate"><a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option><a-select-option v-for="c in collectionListResForUpdate.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option></a-select></a-form-item>
        <a-form-item label="ID" name="id" :rules="[{ required: true }]"><a-input v-model:value="formData.id" /></a-form-item>
        <a-form-item :label="T('Username')"><a-input v-model:value="formData.username" /></a-form-item>
        <a-form-item :label="T('Alias')"><a-input v-model:value="formData.alias" /></a-form-item>
        <a-form-item :label="T('Hash')"><a-input v-model:value="formData.hash" /></a-form-item>
        <a-form-item :label="T('Hostname')"><a-input v-model:value="formData.hostname" /></a-form-item>
        <a-form-item :label="T('Platform')"><a-select v-model:value="formData.platform"><a-select-option v-for="item in platformList" :key="item.value" :value="item.value">{{ item.label }}</a-select-option></a-select></a-form-item>
        <a-form-item :label="T('Tags')"><a-select v-model:value="formData.tags" mode="multiple"><a-select-option v-for="item in tagListRes.list" :key="item.name" :value="item.name">{{ item.name }}</a-select-option></a-select></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="shareToWebClientVisible" :footer="null" :closable="false">
      <shareByWebClient :id="shareToWebClientForm.id" :hash="shareToWebClientForm.hash" @cancel="shareToWebClientVisible = false" @success="" />
    </a-modal>

    <a-modal v-model:open="batchEditTagVisible" :title="T('BatchEditTags')" @ok="submitBatchEditTags" @cancel="batchEditTagVisible = false">
      <a-form :model="batchEditTagsFormData" layout="vertical" class="dialog-form" style="margin-top: 20px;">
        <a-form-item :label="T('Tags')"><a-select v-model:value="batchEditTagsFormData.tags" mode="multiple"><a-select-option v-for="item in tagListResForBatchEdit.list" :key="item.name" :value="item.name">{{ item.name }}</a-select-option></a-select></a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
  import { onActivated, onMounted, reactive, ref, watch, computed } from 'vue'
  import { useBatchUpdateTagsRepositories, useRepositories } from '@/views/address_book'
  import { toWebClientLink } from '@/utils/webclient'
  import { T } from '@/utils/i18n'
  import shareByWebClient from '@/views/address_book/components/shareByWebClient.vue'
  import { useAppStore } from '@/store/app'
  import { connectByClient } from '@/utils/peer'
  import { handleClipboard } from '@/utils/clipboard'
  import PlatformIcons from '@/components/icons/platform.vue'

  const appStore = useAppStore()
  const {
    listRes, listQuery, getList, handlerQuery, collectionListRes, getCollectionList,
    del,
    formVisible, platformList, formData, toEdit, toAdd, submit,
    tagListRes, changeCollectionForUpdate, getCollectionListForUpdate, collectionListResForUpdate,
  } = useRepositories('my')

  const columns = computed(() => [
    { title: 'ID', key: 'id', align: 'center', width: 200 },
    { title: T('AddressBookName'), key: 'collection_id', align: 'center', width: 150 },
    { title: T('Username'), dataIndex: 'username', align: 'center', width: 150 },
    { title: T('Hostname'), dataIndex: 'hostname', align: 'center', width: 150 },
    { title: T('Tags'), dataIndex: 'tags', align: 'center' },
    { title: T('Alias'), dataIndex: 'alias', align: 'center', width: 150 },
    { title: T('Version'), dataIndex: ['peer', 'version'], align: 'center', width: 100 },
    { title: T('Hash'), dataIndex: 'hash', align: 'center', width: 150, ellipsis: true },
    { title: T('Actions'), key: 'actions', align: 'center', width: 600, fixed: 'right' },
  ]);

  onMounted(getCollectionList)
  onMounted(getCollectionListForUpdate)
  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)

  const shareToWebClientVisible = ref(false)
  const shareToWebClientForm = reactive({ id: '', hash: '' })
  const toShowShare = (row) => {
    shareToWebClientForm.id = row.id
    shareToWebClientForm.hash = row.hash
    shareToWebClientVisible.value = true
  }

  const {
    tagListRes: tagListResForBatchEdit,
    getTagList: getTagListForBatchEdit,
    visible: batchEditTagVisible,
    show: showBatchEditTags,
    formData: batchEditTagsFormData,
    submit: _submitBatchEditTags,
  } = useBatchUpdateTagsRepositories()
  onMounted(getTagListForBatchEdit)
  const submitBatchEditTags = async () => {
    const res = await _submitBatchEditTags().catch(_ => false)
    if (res) {
      getList()
    }
  }

  const selectedRowKeys = ref([]);
  const onSelectChange = (keys, selectedRows) => {
    selectedRowKeys.value = keys;
    batchEditTagsFormData.value.row_ids = selectedRows.map(v => v.row_id)
  }
</script>

<style scoped lang="scss">
</style>