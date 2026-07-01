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
    <a-modal v-model:open="formVisible" :title="!formData.id ? T('Create') : T('Update')" @ok="submit" @cancel="formVisible = false" width="800px">
      <a-form class="dialog-form" ref="form" :model="formData" :rules="rules" layout="vertical" style="margin-top: 20px;">
        <a-form-item label="Type" name="oauth_type">
          <a-radio-group v-model:value="formData.oauth_type" :disabled="!!formData.id">
            <a-radio v-for="item in types" :key="item.value" :value="item.value">{{ item.label }}</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item v-if="formData.oauth_type === 'oidc'" label="IdP" name="op"><a-input v-model:value="formData.op" :placeholder="T('Your IdP Name')" /></a-form-item>
        <a-form-item v-if="formData.oauth_type === 'oidc'" label="Issuer" name="issuer"><a-input v-model:value="formData.issuer" :placeholder="`${T('Check your IdP docs, without')} '/.well-known/openid-configuration'`" /></a-form-item>
        <a-form-item v-show="formData.oauth_type === 'oidc'" label="Scopes" name="scopes"><a-input v-model:value="formData.scopes" :placeholder="`${T('Optional, default is')} 'openid,profile,email'`" /></a-form-item>
        <a-form-item label="ClientId" name="client_id"><a-input v-model:value="formData.client_id" /></a-form-item>
        <a-form-item label="ClientSecret" name="client_secret"><a-input-password v-model:value="formData.client_secret" /></a-form-item>
        <a-form-item label="RedirectUrl" name="redirect_url">
          <a-input-search v-model:value="defaultRedirectUrl" readonly @search="copyRedirectUrl">
            <template #enterButton><a-button><CopyOutlined /></a-button></template>
          </a-input-search>
        </a-form-item>
        <a-form-item label="PkceEnable" name="pkce_enable"><a-switch v-model:checked="formData.pkce_enable" /></a-form-item>
        <a-form-item v-if="formData.pkce_enable" label="PkceMethod" name="pkce_method">
          <a-select v-model:value="formData.pkce_method" placeholder="Select PKCE Method">
            <a-select-option value="S256">S256 (Recommended)</a-select-option>
            <a-select-option value="plain">Plain</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="T('AutoRegister')" name="auto_register">
          <a-switch v-model:checked="formData.auto_register" />
          <span style="margin-left: 10px;">{{ T('AutoRegisterNote') }}</span>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
  import { onMounted, reactive, watch, ref, onActivated, computed, h } from 'vue'
  import { list, create, update, remove } from '@/api/oauth'
  import { message, Modal } from 'ant-design-vue'
  import { ExclamationCircleOutlined } from '@ant-design/icons-vue'
  import { T } from '@/utils/i18n'
  import { handleClipboard } from '@/utils/clipboard'
  import { useAppStore } from '@/store/app'

  const app = useAppStore()

  const defaultRedirectUrl = computed(() => `${app.setting.rustdeskConfig.api_server || window.location.origin}/api/oidc/callback`)
  const copyRedirectUrl = (e) => {
    handleClipboard(defaultRedirectUrl.value)
  }

  const listRes = reactive({ list: [], total: 0, loading: false })
  const listQuery = reactive({ page: 1, page_size: 10 })
  const types = [
    { value: 'github', label: 'GitHub' },
    { value: 'google', label: 'Google' },
    { value: 'linuxdo', label: 'LinuxDo' },
    { value: 'oidc', label: 'OIDC' },
  ]

  const columns = computed(() => [
    { title: 'ID', dataIndex: 'id', key: 'id', align: 'center' },
    { title: T('IdP'), dataIndex: 'op', key: 'op', align: 'center' },
    { title: T('Type'), dataIndex: 'oauth_type', key: 'oauth_type', align: 'center' },
    { title: T('AutoRegister'), dataIndex: 'auto_register', key: 'auto_register', align: 'center', customRender: ({ text }) => String(text) },
    { title: T('PkceEnable'), dataIndex: 'pkce_enable', key: 'pkce_enable', align: 'center', customRender: ({ text }) => String(text) },
    { title: T('PkceMethod'), dataIndex: 'pkce_method', key: 'pkce_method', align: 'center' },
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
  const formData = reactive({
    id: 0, op: '', oauth_type: '', issuer: '', client_id: '', client_secret: '',
    redirect_url: '', scopes: '', auto_register: false, pkce_enable: false, pkce_method: 'S256',
  })
  const rules = {
    client_id: [{ required: true, message: () => T('ParamRequired', { param: 'client_id' }) }],
    client_secret: [{ required: true, message: () => T('ParamRequired', { param: 'client_secret' }) }],
    oauth_type: [{ required: true, message: () => T('ParamRequired', { param: 'oauth_type' }) }],
    issuer: [{ required: true, message: () => T('ParamRequired', { param: 'issuer' }) }],
    pkce_method: [{
      validator: (rule, value) => {
        if (formData.pkce_enable && !['S256', 'plain'].includes(value)) {
          return Promise.reject(new Error(T('InvalidParam', { param: 'pkce_method' })))
        }
        return Promise.resolve()
      }
    }],
  }

  const toEdit = (row) => {
    formVisible.value = true
    Object.keys(formData).forEach(key => { formData[key] = row[key] })
  }
  const toAdd = () => {
    formVisible.value = true
    Object.keys(formData).forEach(key => {
      if (typeof formData[key] === 'string') formData[key] = ''
      if (typeof formData[key] === 'number') formData[key] = 0
      if (typeof formData[key] === 'boolean') formData[key] = false
    })
    formData.pkce_method = 'S256'
  }

  const form = ref(null)
  const submit = () => {
    form.value.validate().then(async () => {
      const api = formData.id ? update : create
      const res = await api(formData).catch(_ => false)
      if (res) {
        message.success(T('OperationSuccess'))
        formVisible.value = false
        getList()
      }
    })
  }
</script>

<style scoped lang="scss">
</style>