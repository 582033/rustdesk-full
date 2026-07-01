<template>
  <div>
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
      <a-table :data-source="listRes.list" :loading="listRes.loading" :columns="columns" bordered :pagination="false" :scroll="{ y: 750 }" :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'type'">
            <a-tag v-if="record.type === 1" color="warning"> {{ T('ToRemote') }}:
              <ArrowRightOutlined />
              {{ record.peer_id }}
            </a-tag>
            <a-tag v-else>{{ T('ToLocal') }}:
              <ArrowRightOutlined />
              {{ record.from_peer }}
            </a-tag>
          </template>
          <template v-if="column.key === 'file_info'">
            <template v-if="!record.is_file">
              <a-table size="small" :data-source="record.info?.files?.slice(0, showDirFileNum)" :pagination="false" style="margin-bottom: 5px;">
                <template #bodyCell="{ column: col, record: fileRecord }">
                  <template v-if="col.key === 'name'"><span :title="fileRecord[0]">{{ fileRecord[0] }}</span></template>
                  <template v-if="col.key === 'size'">{{ sizeFormat(fileRecord[1]) }}</template>
                </template>
              </a-table>
              <a-button v-if="record.info.files.length > showDirFileNum" type="primary" size="small" @click="showAllFile(record.info.files)" style="width: 100%;">{{ T('More') }}({{ record.info.files.length - showDirFileNum }})</a-button>
            </template>
            <div v-else>{{ sizeFormat(record.info.files[0][1]) }}</div>
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
    <a-modal v-model:open="allFilesVisible" :title="T('File')" @ok="allFilesVisible = false" @cancel="allFilesVisible = false">
      <a-table :data-source="showFiles" :pagination="false" :scroll="{ y: 800 }">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'index'">{{ record.index }}</template>
          <template v-if="column.key === 'name'">{{ record[0] }}</template>
          <template v-if="column.key === 'size'">{{ sizeFormat(record[1]) }}</template>
        </template>
      </a-table>
    </a-modal>
  </div>
</template>

<script setup>
  import { onActivated, onMounted, ref, watch, computed } from 'vue'
  import { useFileRepositories } from '@/views/audit/reponsitories'
  import { T } from '@/utils/i18n'
  import { sizeFormat } from '@/utils/file'

  const showDirFileNum = 3
  const {
    listRes, listQuery, getList, handlerQuery, del, batchdel, toExport,
  } = useFileRepositories()

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center', width: 100 },
    { title: T('Peer'), dataIndex: 'peer_id', key: 'peer_id', align: 'center', width: 120 },
    { title: T('FromPeer'), dataIndex: 'from_peer', key: 'from_peer', align: 'center', width: 120 },
    { title: T('FromName'), dataIndex: 'from_name', key: 'from_name', align: 'center', width: 120 },
    { title: T('Ip'), dataIndex: 'ip', key: 'ip', align: 'center', width: 120 },
    { title: T('Type'), key: 'type', align: 'center', width: 200 },
    { title: T('Num'), dataIndex: 'num', key: 'num', align: 'center', width: 100 },
    { title: T('FileInfo'), key: 'file_info', align: 'center', width: 300 },
    { title: T('Path'), dataIndex: 'path', key: 'path', align: 'center', width: 150, ellipsis: true },
    { title: 'UUID', dataIndex: 'uuid', key: 'uuid', align: 'center', width: 120, ellipsis: true },
    { title: T('CreatedAt'), dataIndex: 'created_at', key: 'created_at', align: 'center', minWidth: 120 },
    { title: T('Actions'), key: 'actions', align: 'center', width: 150, fixed: 'right' },
  ]);

  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, handlerQuery)

  const allFilesVisible = ref(false)
  const showFiles = ref([])
  const showAllFile = (files) => {
    showFiles.value = files.map((file, index) => ({ index: index + 1, 0: file[0], 1: file[1] }))
    allFilesVisible.value = true
  }

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
</style>