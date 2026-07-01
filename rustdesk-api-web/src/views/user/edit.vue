<template>
  <div class="form-card">
    <a-card>
      <a-form ref="root" :model="form" :rules="rules" :label-col="{ span: 4 }" :wrapper-col="{ span: 14 }">
        <a-form-item :label="T('Username')" name="username">
          <a-input v-model:value="form.username" />
        </a-form-item>
        <a-form-item :label="T('Email')" name="email">
          <a-input v-model:value="form.email" />
        </a-form-item>
        <a-form-item :label="T('Nickname')" name="nickname">
          <a-input v-model:value="form.nickname" />
        </a-form-item>
        <a-form-item :label="T('Group')" name="group_id">
          <a-select v-model:value="form.group_id">
            <a-select-option
                v-for="item in groupsList"
                :key="item.id"
                :value="item.id"
            >{{ item.name }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="T('IsAdmin')" name="is_admin">
          <a-switch v-model:checked="form.is_admin" />
        </a-form-item>
        <a-form-item :label="T('Status')" name="status">
          <a-switch :checked="form.status === ENABLE_STATUS" @change="checked => form.status = checked ? ENABLE_STATUS : DISABLE_STATUS" />
        </a-form-item>
        <a-form-item :label="T('Remark')" name="remark">
          <a-input v-model:value="form.remark" />
        </a-form-item>
        <a-form-item :wrapper-col="{ offset: 4, span: 14 }">
          <a-button @click="cancel">{{ T('Cancel') }}</a-button>
          <a-button @click="submit" type="primary" style="margin-left: 8px;">{{ T('Submit') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
  </div>
</template>

<script setup>
  import { useRoute } from 'vue-router'
  import { useGetDetail, useSubmit } from '@/views/user/composables/edit'
  import { ENABLE_STATUS, DISABLE_STATUS } from '@/utils/common_options'
  import { T } from '@/utils/i18n'

  const route = useRoute()
  const { form, getDetail, groupsList } = useGetDetail(route.params.id)
  const { root, rules, submit, cancel } = useSubmit(form, route.params.id)
</script>

<style lang="scss" scoped>
.form-card {
  padding: 20px;
}
</style>