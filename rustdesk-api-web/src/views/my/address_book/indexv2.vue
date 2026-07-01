<template>
  <div class="address-book-con">
    <div class="aside">
      <a-select style="width: 100%;" v-model:value="listQuery.collection_id" filterable>
        <a-select-option :value="0">{{ T('MyAddressBook') }}</a-select-option>
        <a-select-option v-for="c in collectionListRes.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option>
      </a-select>
      <div class="aside-tags">
        <div class="top" style="width: 100%">标签</div>
        <div v-for="t in tagListRes.list"
             :key="t.id" class="tag"
             :class="{checked: checkedTags.includes(t.name)}"
             :style="{backgroundColor: checkedTags.includes(t.name)?t.color:''}"
             @click="toggleTag(t)"
        >
          <span class="dot" :style="{background:checkedTags.includes(t.name)?'#fff':t.color}"></span> <span>{{ t.name }}</span>
        </div>

      </div>
    </div>

    <div class="con">
      <a-card class="list-query">
        <a-form layout="inline">
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
            <a-button danger @click="toAdd" style="margin-left: 8px;">{{ T('Add') }}</a-button>
          </a-form-item>
        </a-form>
      </a-card>
      <a-card class="list-body" style="margin-top: 16px;">
        <a-table :data-source="listRes.list" :loading="listRes.loading" bordered :pagination="false" :row-key="record => record.id">
          <a-table-column key="id" title="ID" data-index="id" align="center" width="200">
            <template #default="{ text: id }">
              <span>{{ id }} <CopyOutlined @click="handleClipboard(id)"/></span>
            </template>
          </a-table-column>
          <a-table-column key="collection_id" :title="T('Name')" data-index="collection_id" align="center" width="150">
            <template #default="{ text: collection_id }">
              <span v-if="collection_id === 0">{{ T('MyAddressBook') }}</span>
              <span v-else>{{ collectionListRes.list.find(c => c.id === collection_id)?.name }}</span>
            </template>
          </a-table-column>
          <a-table-column key="username" :title="T('Username')" data-index="username" align="center" width="150"/>
          <a-table-column key="hostname" :title="T('Hostname')" data-index="hostname" align="center" width="150"/>
          <a-table-column key="platform" :title="T('Platform')" data-index="platform" align="center" width="120"/>
          <a-table-column key="tags" :title="T('Tags')" data-index="tags" align="center"/>
          <a-table-column key="alias" :title="T('Alias')" data-index="alias" align="center" width="150"/>
          <a-table-column key="hash" :title="T('Hash')" data-index="hash" align="center" width="150" :ellipsis="true"/>
          <a-table-column key="actions" :title="T('Actions')" align="center" class-name="table-actions" width="600" fixed="right">
            <template #default="{ record }">
              <a-button type="primary" ghost @click="connectByClient(record.id)">{{ T('Link') }}</a-button>
              <a-button v-if="appStore.setting.appConfig.web_client" type="primary" ghost @click="toWebClientLink(record)" style="margin-left: 8px;">Web Client</a-button>
              <a-button v-if="appStore.setting.appConfig.web_client" type="primary" @click="toShowShare(record)" style="margin-left: 8px;">{{ T('ShareByWebClient') }}</a-button>
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
    </div>


    <a-modal v-model:open="formVisible" width="800" :title="!formData.row_id?T('Create') :T('Update') ">
      <a-form class="dialog-form" ref="form" :model="formData" layout="vertical">
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
                v-for="item in tagList"
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
    <a-modal v-model:open="shareToWebClientVisible" width="900" :footer="null">
      <shareByWebClient :id="shareToWebClientForm.id"
                        :hash="shareToWebClientForm.hash"
                        @cancel="shareToWebClientVisible=false"
                        @success=""/>
    </a-modal>
  </div>
</template>

<script setup>
  import { onActivated, onMounted, ref, watch } from 'vue'
  import { list as fetchTagList } from '@/api/tag'
  import { useRepositories } from '@/views/address_book'
  import { useRepositories as useCollectionRepositories } from '@/views/address_book/collection'
  import { useRepositories as useTagRepositories } from '@/views/tag/index'
  import { toWebClientLink } from '@/utils/webclient'
  import { T } from '@/utils/i18n'
  import shareByWebClient from '@/views/address_book/components/shareByWebClient.vue'
  import { useAppStore } from '@/store/app'
  import { connectByClient } from '@/utils/peer'
  import { handleClipboard } from '@/utils/clipboard'
  import { CopyOutlined } from '@ant-design/icons-vue'

  const appStore = useAppStore()
  const tagList = ref([])
  const fetchTagListData = async () => {
    const res = await fetchTagList({ is_my: 1 }).catch(_ => false)
    if (res) {
      tagList.value = res.data.list
    }
  }
  fetchTagListData()

  const {
    listRes,
    listQuery,
    getList,
    handlerQuery,
    del,
    formVisible,
    platformList,
    formData,
    toEdit,
    toAdd,
    submit,
    shareToWebClientVisible,
    shareToWebClientForm,
    toShowShare,
  } = useRepositories()

  listQuery.is_my = 1

  onMounted(getList)
  onActivated(getList)

  watch(() => listQuery.page, getList)
  watch(() => listQuery.page_size, getList)

  const {
    listRes: collectionListRes,
    listQuery: collectionListQuery,
    getList: getCollectionList,
  } = useCollectionRepositories()
  collectionListQuery.is_my = 1
  collectionListQuery.page_size = 999
  onMounted(getCollectionList)

  const {
    listRes: tagListRes,
    listQuery: tagListQuery,
    getList: getTagList,
  } = useTagRepositories()
  tagListQuery.is_my = 1
  tagListQuery.page_size = 999
  onMounted(getTagList)
  const checkedTags = ref([])
  const toggleTag = async (tag) => {
    if (checkedTags.value.includes(tag.name)) {
      checkedTags.value = checkedTags.value.filter(t => t !== tag.name)
    } else {
      checkedTags.value.push(tag.name)
    }
  }
</script>

<style scoped lang="scss">
.address-book-con {
  display: flex;
  height: calc(100vh - 120px);

  .aside {
    width: 200px;
    padding-right: 16px;

    .aside-tags {
      margin-top: 15px;
      border: 1px solid #eee;
      border-radius: 5px;
      min-height: calc(100vh - 200px);
      padding: 10px;
      display: flex;
      flex-wrap: wrap;
      align-content: start;

      .tag {
        margin-right: 10px;
        margin-bottom: 5px;
        padding: 0 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        line-height: 1;
        height: 28px;
        background-color: var(--tag-bg-color);
        font-size: 14px;
        border-radius: 8px;
        cursor: pointer;

        &.checked {
          color: #fff;
        }

        span {
          display: block;
        }

        .dot {
          width: 8px;
          height: 8px;
          display: block;
          border-radius: 50%;
          line-height: 1;
          font-size: 12px;
          margin-right: 6px;
        }
      }
    }
  }

  .con {
    flex: 1;
    padding-top: 0;
  }
}
</style>
