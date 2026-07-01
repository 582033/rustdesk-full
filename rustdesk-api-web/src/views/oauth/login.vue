<template>
  <div class="oauth">
    <a-card class="card">
      <h2>{{ T('OauthLogining') }}</h2>
      <a-form class="info" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
        <a-form-item :label="T('Device')">
          <div class="impt">{{ oauthInfo.device_name }}</div>
        </a-form-item>
        <a-form-item label="ID">
          <div class="impt">{{ oauthInfo.id }}</div>
        </a-form-item>
        <a-form-item :wrapper-col="{ span: 24 }">
          <a-button style="width: 100%" v-if="!resStatus" type="primary" size="large" @click="toConfirm">{{ T('ConfirmOauth') }}</a-button>
        </a-form-item>
        <a-form-item :wrapper-col="{ span: 24 }">
          <a-button style="width: 100%" size="large" @click="out">{{ T('Close') }}</a-button>
        </a-form-item>
      </a-form>
      {{ T('OauthCloseNote') }}
    </a-card>
  </div>
</template>

<script setup>
  import { ref } from 'vue'
  import { info, confirm } from '@/api/oauth'
  import { useRoute } from 'vue-router'
  import { message } from 'ant-design-vue'
  import { T } from '@/utils/i18n'

  const oauthInfo = ref({})
  const route = useRoute()
  const code = route.params?.code
  if (!code) {
    // router.push('/')
  }
  const getInfo = async () => {
    const res = await info({ code }).catch(_ => false)
    if (res) {
      oauthInfo.value = res.data
    } else {
      // router.push('/')
    }
  }
  getInfo()
  const resStatus = ref(0)
  const toConfirm = async () => {
    const res = await confirm({ code }).catch(_ => false)
    if (res) {
      resStatus.value = 1
      message.success(T('OperationSuccessAndCloseAfter3Seconds'))
      setTimeout(_ => {
        out()
      }, 3000)
    }
  }
  const out = () => {
    window.close()
  }

</script>

<style scoped lang="scss">
.oauth {
  width: 100vw;
  height: 100vh;
  background-color: #2d3a4b;
  padding-top: 25vh;
  box-sizing: border-box;

  .card {
    max-width: 500px;
    background-color: #283342;
    color: #fff;
    border: none;
    margin: 0 auto;
    text-align: center;

    .info {
      display: block;
      line-height: 30px;
      margin-bottom: 50px;

      :deep(.ant-form-item-label > label) {
        color: #fff;
      }
    }

    .impt {
      font-weight: bold;
      font-size: 20px;
    }
  }
}
</style>
