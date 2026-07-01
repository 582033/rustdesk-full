<template>
  <div class="login-container">
    <div class="login-card">
      <img src="@/assets/logo.png" alt="logo" class="login-logo"/>
      <a-form ref="f" :model="form" layout="vertical" class="login-form" :rules="rules">
        <a-form-item :label="T('Username')" name="username">
          <a-input v-model:value="form.username" class="login-input"></a-input>
        </a-form-item>

        <a-form-item :label="T('Email')" name="email">
          <a-input v-model:value="form.email" class="login-input"></a-input>
        </a-form-item>

        <a-form-item :label="T('Password')" name="password">
          <a-input-password v-model:value="form.password" class="login-input"></a-input-password>
        </a-form-item>
        <a-form-item :label="T('ConfirmPassword')" name="confirm_password">
          <a-input-password v-model:value="form.confirm_password" @keyup.enter="submit"
                            class="login-input"></a-input-password>
        </a-form-item>
        <a-form-item>
          <a-button @click="submit" class="login-button" type="primary">{{ T('Submit') }}</a-button>
          <a-button @click="toLogin" class="login-button" style="margin-top: 8px;">{{ T('ToLogin') }}</a-button>
        </a-form-item>
      </a-form>
    </div>
  </div>
</template>

<script setup>
  import { reactive, ref } from 'vue'
  import { message } from 'ant-design-vue'
  import { T } from '@/utils/i18n'
  import { useRouter } from 'vue-router'
  import { register } from '@/api/user'
  import { useUserStore } from '@/store/user'
  import { useAppStore } from '@/store/app'

  const router = useRouter()
  const userStore = useUserStore()
  const form = reactive({
    username: '',
    email: '',
    password: '',
    confirm_password: '',
  })
  const rules = {
    username: [
      { required: true, message: T('ParamRequired', { param: T('Username') }), trigger: 'blur' },
    ],
    password: [
      { required: true, message: T('ParamRequired', { param: T('Password') }), trigger: 'blur' },
    ],
    confirm_password: [
      { required: true, message: T('ParamRequired', { param: T('ConfirmPassword') }), trigger: 'blur' },
      {
        validator: (rule, value, callback) => {
          if (value !== form.password) {
            callback(new Error(T('PasswordNotMatchConfirmPassword')))
          } else {
            callback()
          }
        }, trigger: 'blur',
      },
    ],
  }
  const f = ref(null)
  const submit = async () => {
    const v = await f.value.validate().catch(_ => false)
    if (!v) {
      return
    }
    const res = await register(form).catch(_ => false)
    if (!res) {
      return
    }
    userStore.saveUserData(res.data)
    useAppStore().loadConfig()
    message.success('Submit')
    router.push('/')
  }
  const toLogin = () => {
    router.push('/login')
  }
</script>

<style scoped lang="scss">
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #2d3a4b;
  padding: 20px;
  box-sizing: border-box;
}

.login-card {
  width: 360px;
  background-color: #283342;
  padding: 40px;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  text-align: center;
}

h1 {
  margin-bottom: 20px;
  font-size: 24px;
  font-weight: bold;
}

.login-form {
  margin-bottom: 20px;
}

.login-input {
  width: 100%;
}

.login-button {
  width: 100%;
  height: 40px;
  margin-bottom: 20px;
  margin-top: 20px;
  margin-left: 0;
}

.login-logo {
  width: 80px;
  height: 80px;
  margin: 0 auto 20px;
  display: block;
}

:deep(.ant-form-item-label > label) {
  color: #fff;
}

:deep(.ant-input), :deep(.ant-input-password) {
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: transparent;
  color: #fff;
}

:deep(.ant-input-password .ant-input) {
  background: transparent;
}
</style>
