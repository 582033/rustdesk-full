<template>

  <a-form class="dialog-form" ref="form" :model="ABFormData" layout="vertical">
    <a-form-item :label="T('Owner')" name="user_ids" :rules="[{ required: true }]">
      <a-select v-model:value="ABFormData.user_ids" mode="multiple" @change="changeUser">
        <a-select-option
            v-for="item in allUsers"
            :key="item.id"
            :value="item.id"
        >{{ item.username }}</a-select-option>
      </a-select>
    </a-form-item>
    <a-form-item :label="T('AddressBookName')" v-if="ABFormData.user_ids.length<=1" :rules="[{ required: true }]" name="collection_id">
      <a-select v-model:value="ABFormData.collection_id" clearable @change="changeCollectionForUpdate">
        <a-select-option :value="0" :label="T('MyAddressBook')">{{ T('MyAddressBook') }}</a-select-option>
        <a-select-option v-for="c in collectionListResForUpdate.list" :key="c.id" :value="c.id">{{ c.name }}</a-select-option>
      </a-select>
    </a-form-item>
    <a-form-item label="ID" name="id" :rules="[{ required: true }]">
      <a-input v-model:value="ABFormData.id"></a-input>
    </a-form-item>
    <a-form-item :label="T('Username')" name="username">
      <a-input v-model:value="ABFormData.username"></a-input>
    </a-form-item>
    <a-form-item :label="T('Alias')" name="alias">
      <a-input v-model:value="ABFormData.alias"></a-input>
    </a-form-item>
    <a-form-item :label="T('Hostname')" name="hostname">
      <a-input v-model:value="ABFormData.hostname"></a-input>
    </a-form-item>
    <a-form-item :label="T('Platform')" name="platform">
      <a-select v-model:value="ABFormData.platform">
        <a-select-option
            v-for="item in ABPlatformList"
            :key="item.value"
            :value="item.value"
        >{{ item.label }}</a-select-option>
      </a-select>
    </a-form-item>

    <a-form-item :label="T('Tags')" name="tags" v-if="ABFormData.user_ids.length<=1">
      <a-select v-model:value="ABFormData.tags" mode="multiple">
        <a-select-option
            v-for="item in tagListRes.list"
            :key="item.name"
            :value="item.name"
        >{{ item.name }}</a-select-option>
      </a-select>
    </a-form-item>
    <a-form-item>
      <a-button @click="cancel">{{ T('Cancel') }}</a-button>
      <a-button @click="ABSubmit" type="primary" style="margin-left: 8px;">{{ T('Submit') }}</a-button>
    </a-form-item>
  </a-form>
</template>
<script setup>

  import { T } from '@/utils/i18n'
  import { loadAllUsers } from '@/global'
  import { onMounted } from 'vue'
  import { useRepositories as useABRepositories } from '@/views/address_book'
  import { batchCreate } from '@/api/address_book'
  import { message } from 'ant-design-vue'

  const emits = defineEmits(['cancel', 'success'])
  const props = defineProps({
    peer: {
      type: Object,
      required: true,
    },
  })
  const { allUsers, getAllUsers } = loadAllUsers()
  onMounted(getAllUsers)
  const {
    platformList: ABPlatformList,
    formData: ABFormData,
    changeUserForUpdate,
    changeCollectionForUpdate,
    collectionListResForUpdate,
    tagListRes,
    fromPeer,
  } = useABRepositories('admin')
  onMounted(() => {
    fromPeer(props.peer)
    console.log(collectionListResForUpdate)
  })

  const changeUser = async (val) => {
    ABFormData.collection_id = 0
    ABFormData.tags = []
    if (val.length === 1) {
      changeUserForUpdate(val[0])
    }
    if (val.length === 0) {
      collectionListResForUpdate.list = []
    }
  }

  const ABSubmit = async () => {
    if (ABFormData.user_ids.length === 0) {
      message.error(T('ParamRequired', { param: T('Owner') }))
      return
    }
    if (!ABFormData.id) {
      message.error(T('ParamRequired', { param: 'ID' }))
      return
    }
    if (ABFormData.user_ids.length > 1) {
      ABFormData.collection_id = 0
      ABFormData.tags = []
    }
    const res = await batchCreate(ABFormData).catch(_ => false)
    if (res) {
      message.success(T('OperationSuccess'))
      emits('success')
    }
  }
  const cancel = () => {
    emits('cancel')
  }

</script>

<style scoped lang="scss">

</style>
