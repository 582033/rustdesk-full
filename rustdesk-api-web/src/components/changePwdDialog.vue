<template>
  <a-modal v-model:open="v" :title="T('ChangePassword')" @ok="changePassword" @cancel="cancelChangePwd">
    <a-form ref="cpwd" :model="changePwdForm" :rules="chagePwdRules" layout="vertical" style="margin-top: 20px">
      <a-form-item :label="T('OldPassword')" name="old_password">
        <a-input-password v-model:value="changePwdForm.old_password" :placeholder="T('For OIDC login without a password, enter any 4-20 letters')" />
      </a-form-item>
      <a-form-item :label="T('NewPassword')" name="new_password">
        <a-input-password v-model:value="changePwdForm.new_password" />
      </a-form-item>
      <a-form-item :label="T('ConfirmPassword')" name="confirmPwd">
        <a-input-password v-model:value="changePwdForm.confirmPwd" />
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<script setup>
  import { computed, reactive, ref, h } from 'vue'
  import { Modal } from 'ant-design-vue'
  import { ExclamationCircleOutlined } from '@ant-design/icons-vue'
  import { changeCurPwd } from '@/api/user'
  import { useUserStore } from '@/store/user'
  import { T } from '@/utils/i18n'

  const props = defineProps({
    visible: Boolean,
  })
  const v = computed({
    get: () => props.visible,
    set: (val) => {
      emit('update:visible', val)
    },
  })
  const emit = defineEmits(['update:visible'])

  const changePwdForm = reactive({
    old_password: '',
    new_password: '',
    confirmPwd: '',
  })

  const chagePwdRules = computed(() => ({
    old_password: [{ required: true, message: T('ParamRequired', { param: T('OldPassword') }), trigger: 'blur' }],
    new_password: [
      { required: true, message: T('ParamRequired', { param: T('NewPassword') }), trigger: 'blur' },
      {
        validator: (rule, value) => {
          if (value === changePwdForm.old_password) {
            return Promise.reject(new Error(T('NewPasswordEqualOldPassword')))
          } else {
            return Promise.resolve()
          }
        },
        trigger: 'blur',
      }
    ],
    confirmPwd: [
      { required: true, message: T('ParamRequired', { param: T('ConfirmPassword') }), trigger: 'blur' },
      {
        validator: (rule, value) => {
          if (value !== changePwdForm.new_password) {
            return Promise.reject(new Error(T('PasswordNotMatchConfirmPassword')))
          } else {
            return Promise.resolve()
          }
        },
        trigger: 'blur',
      },
    ],
  }))

  const cpwd = ref(null)
  const cancelChangePwd = () => {
    cpwd.value.resetFields();
    emit('update:visible', false)
  }

  const userStore = useUserStore()

  const changePassword = () => {
    cpwd.value.validate().then(() => {
      Modal.confirm({
        title: T('Confirm?'),
        icon: h(ExclamationCircleOutlined),
        content: T('Confirm?', { param: T('ChangePassword') }),
        okText: T('Confirm'),
        cancelText: T('Cancel'),
        onOk: async () => {
          const res = await changeCurPwd(changePwdForm).catch(_ => false)
          if (!res) {
            return
          }
          Modal.success({
            title: T('OperationSuccess'),
            content: T('ChangePasswordSuccess'),
            onOk: () => {
              userStore.logout()
              window.location.reload()
            }
          });
        },
      });
    }).catch(err => {
      console.log('error', err);
    });
  }
</script>

<style scoped lang="scss">
</style>