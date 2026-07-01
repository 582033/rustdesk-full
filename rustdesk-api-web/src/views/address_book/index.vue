<template>
  <div>
    <a-card class="list-query">
      <a-form layout="inline">
        <a-form-item :label="T('Owner')">
          <a-select v-model:value="listQuery.user_id" clearable @change="changeQueryUser" style="width: 160px">
            <a-select-option
                v-for="item in allUsers"
                :key="item.id"
                :value="item.id"
            >{{ item.username }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="T('AddressBookName')">
          <a-select v-model:value="listQuery.collection_id" clearable style="width: 160px">
            <a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option>
            <a-select-option v-for="c in collectionListRes.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="T('Id')">
          <a-input v-model:value="listQuery.id" clearable></a-input>
        </a-form-item>
        <a-form-item :label="T('Username')">
          <a-input v-model:value="listQuery.username" clearable></a-input>
        </a-form-item>
        <a-form-item :label="T('Hostname')">
          <a-input v-model:value="listQuery.hostname" clearable></a-input>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handlerQuery">{{ T('Filter') }}</a-button>
          <a-button type="primary" @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
    <a-card class="list-body" style="margin-top: 16px;">
      <a-table :data-source="listRes.list" :loading="listRes.loading" bordered :pagination="false" :row-key="record => record.id">
        <a-table-column key="id" title="ID" data-index="id" align="center" width="200">
          <template #default="{ record }">
            <div>
              <PlatformIcons :name="platformList.find(p=>p.label===record.platform)?.icon" style="width: 20px;height: 20px;display: inline-block" color="var(--basicBlack)"/>
              {{ record.id }}
              <CopyOutlined @click="handleClipboard(record.id)"/>
            </div>
          </template>
        </a-table-column>
        <a-table-column key="user_id" :title="T('Owner')" data-index="user_id" align="center" width="200">
          <template #default="{ text: user_id }">
            <span v-if="user_id"> <a-tag>{{ allUsers?.find(u => u.id === user_id)?.username }}</a-tag> </span>
          </template>
        </a-table-column>
        <a-table-column key="collection_id" :title="T('AddressBookName')" data-index="collection_id" align="center" width="150">
          <template #default="{ record }">
            <span v-if="record.collection_id === 0">{{ T('MyAddressBook') }}</span>
            <span v-else>{{ record.collection?.name }}</span>
          </template>
        </a-table-column>
        <a-table-column key="username" :title="T('Username')" data-index="username" align="center" width="150"/>
        <a-table-column key="hostname" :title="T('Hostname')" data-index="hostname" align="center" width="150"/>
        <a-table-column key="tags" :title="T('Tags')" data-index="tags" align="center"/>
        <a-table-column key="version" :title="T('Version')" data-index="peer.version" align="center" width="100"/>
        <a-table-column key="hash" :title="T('Hash')" data-index="hash" align="center" width="150" :ellipsis="true"/>
        <a-table-column key="actions" :title="T('Actions')" align="center" class-name="table-actions" width="500" fixed="right">
          <template #default="{record}">
            <a-button type="primary" ghost @click="connectByClient(record.id)">{{ T('Link') }}</a-button>
            <a-button v-if="appStore.setting.appConfig.web_client" type="primary" ghost @click="toWebClientLink(record)" style="margin-left: 8px;">Web Client</a-button>
            <a-button @click="toEdit(record)" style="margin-left: 8px;">{{ T('Edit') }}</a-button>
            <a-button danger @click="del(record)" style="margin-left: 8px;">{{ T('Delete') }}</a-button>
          </template>
        </a-table-column>
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
    <a-modal v-model:open="formVisible" width="800" :title="!formData.row_id?T('Create') :T('Update') ">
      <a-form class="dialog-form" ref="form" :model="formData" layout="vertical">
        <a-form-item :label="T('Owner')" name="user_id" :rules="[{ required: true }]">
          <a-select v-model:value="formData.user_id" @change="changeUserForUpdate">
            <a-select-option
                v-for="item in allUsers"
                :key="item.id"
                :value="item.id"
            >{{ item.username }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="T('AddressBookName')">
          <a-select v-model:value="formData.collection_id" clearable @change="changeCollectionForUpdate">
            <a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option>
            <a-select-option v-for="c in collectionListResForUpdate.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="ID" name="id" :rules="[{ required: true }]">
          <a-input v-model:value="formData.id"></a-input>
        </a-form-item>
        <a-form-item :label="T('Username')" name="username">
          <a-input v-model:value="formData.username"></a-input>
        </a-form-item>
        <a-form-item :label="T('Alias')" name="alias">
          <a-input v-model:value="formData.alias"></a-input>
        </a-form-item>
        <a-form-item :label="T('Hash')" name="hash">
          <a-input v-model:value="formData.hash"></a-input>
        </a-form-item>
        <a-form-item :label="T('Hostname')" name="hostname">
          <a-input v-model:value="formData.hostname"></a-input>
        </a-form-item>
        <a-form-item :label="T('Platform')" name="platform">
          <a-select v-model:value="formData.platform">
            <a-select-option
                v-for="item in platformList"
                :key="item.value"
                :value="item.value"
            >{{ item.label }}</a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item :label="T('Tags')" name="tags">
          <a-select v-model:value="formData.tags" mode="multiple">
            <a-select-option
                v-for="item in tagListRes.list"
                :key="item.name"
                :value="item.name"
            >{{ item.name }}</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
       <template #footer>
        <a-button @click="formVisible = false">{{ T('Cancel') }}</a-button>
        <a-button @click="submit" type="primary">{{ T('Submit') }}</a-button>
      </template>
    </a-modal>
  </div>
</template>

<script setup>
  import { onActivated, onMounted, watch } from 'vue'
  import { useRepositories } from '@/views/address_book/index'
  import { toWebClientLink } from '@/utils/webclient'
  import { T } from '@/utils/i18n'
  import { useRoute } from 'vue-router'
  import { connectByClient } from '@/utils/peer'
  import { useAppStore } from '@/store/app'
  import { handleClipboard } from '@/utils/clipboard'
  import { CopyOutlined } from '@ant-design/icons-vue'
  import PlatformIcons from '@/components/icons/platform.vue'
  import { loadAllUsers } from '@/global'

  const appStore = useAppStore()
  const route = useRoute()
  const { allUsers, getAllUsers } = loadAllUsers()

  const {
    listRes,
    listQuery,
    getList,
    handlerQuery,
    collectionListRes,

    del,
    formVisible,
    platformList,
    formData,
    toEdit,
    toAdd,
    submit,
    changeUserForUpdate,
    changeCollectionForUpdate,
    collectionListResForUpdate,
    tagListRes,

    changeQueryUser,
  } = useRepositories('admin')

  if (route.query?.user_id) {
    listQuery.user_id = parseInt(route.query.user_id)
  }
  onMounted(getAllUsers)
  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)

  watch(() => listQuery.page_size, handlerQuery)


</script>

<style scoped lang="scss">
.colors {
  display: flex;
  justify-content: center;
  align-items: center;

  .colorbox {
    width: 50px;
    height: 30px;
    display: flex;
    justify-content: center;
    align-items: center;

    .dot {
      width: 10px;
      height: 10px;
      display: block;
      border-radius: 50%;
    }
  }

}

</style>
