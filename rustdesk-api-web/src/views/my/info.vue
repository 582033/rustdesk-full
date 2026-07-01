<template>
  <div>
    <a-card :title="T('Userinfo')" shadow="hover">
      <a-form class="info-form" ref="form" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
        <a-form-item :label="T('Username')">
          <div>{{ userStore.username }}</div>
        </a-form-item>
        <a-form-item :label="T('Password')">
          <a-button type="primary" danger @click="showChangePwd">{{ T('ChangePassword') }}</a-button>
        </a-form-item>
        <!-- <a-form-item label="OIDC">
          <a-table :data-source="oidcData" :columns="columns" bordered rowKey="op">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'status'">
                <a-tag v-if="record.status === 1" color="success">{{ T('HasBind') }}</a-tag>
                <a-tag v-else color="error">{{ T('NoBind') }}</a-tag>
              </template>
              <template v-if="column.key === 'actions'">
                <a-button v-if="record.status === 1" type="primary" danger size="small" @click="toUnBind(record)">{{ T('UnBind') }}</a-button>
                <a-button v-else type="primary" size="small" @click="toBind(record)">{{ T('ToBind') }}</a-button>
              </template>
            </template>
          </a-table>
        </a-form-item> -->
      </a-form>
    </a-card>
    <a-card shadow="hover" style="margin-top: 20px">
    </a-card>
    <changePwdDialog v-model:visible="changePwdVisible"></changePwdDialog>
  </div>
</template>

<script setup>
  import changePwdDialog from '@/components/changePwdDialog.vue'
  import { computed, ref, h } from 'vue'
  import { useUserStore } from '@/store/user'
  import { useAppStore } from '@/store/app'
  import { bind, unbind } from '@/api/oauth'
  import { myOauth } from '@/api/user'
  import { Modal } from 'ant-design-vue'
  import { ExclamationCircleOutlined } from '@ant-design/icons-vue'
  import { T } from '@/utils/i18n'
  import { marked } from 'marked'

  const appStore = useAppStore()
  const userStore = useUserStore()
  const changePwdVisible = ref(false)
  const showChangePwd = () => {
    changePwdVisible.value = true
  }
  const oidcData = ref([])

  const columns = [
    { title: T('IdP'), dataIndex: 'op', key: 'op', align: 'center' },
    { title: T('Status'), dataIndex: 'status', key: 'status', align: 'center' },
    { title: T('Actions'), key: 'actions', align: 'center', width: 200 },
  ];

  const getMyOauth = async () => {
    const res = await myOauth().catch(_ => false)
    if (res) {
      oidcData.value = res.data
    }
  }
  getMyOauth()

  const toBind = async (row) => {
    const res = await bind({ op: row.op }).catch(_ => false)
    if (res) {
      const { code, url } = res.data
      window.open(url)
    }
  }

  const toUnBind = (row) => {
    Modal.confirm({
      title: T('Confirm?'),
      icon: h(ExclamationCircleOutlined),
      content: T('Confirm?', { param: T('UnBind') }),
      okText: T('Confirm'),
      cancelText: T('Cancel'),
      onOk: async () => {
        const res = await unbind({ op: row.op }).catch(_ => false)
        if (res) {
          getMyOauth()
        }
      },
    });
  }

</script>

<style scoped lang="scss">
.info-form {
  width: 600px;
  margin: 0 auto;
}
</style>
