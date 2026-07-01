<template>
  <div class="upload-order-file">
    <a-upload
        ref="upload"
        :before-upload="beforeFileUpload"
        :on-success="fileUploadSuccess"
        :on-remove="fileRemove"
        :on-error="onError"
        name="file"
        :file-list="fileList"
        :action="fileUploadHost"
        :data="fileUploadData"
        :headers="headers"
        list-type="picture-card"
        :accept="accept"
        @preview="handlePreview"
    >
      <div v-if="!modelValue">
        <plus-outlined />
        <div class="ant-upload-text">{{ T('Upload') }}</div>
      </div>
    </a-upload>
    <a-modal :open="previewVisible" :title="previewTitle" :footer="null" @cancel="handleCancel">
      <img alt="example" style="width: 100%" :src="previewImage" />
    </a-modal>
  </div>
</template>
<script>
  import { defineComponent, ref, computed, reactive, toRefs } from 'vue'
  import { PlusOutlined } from '@ant-design/icons-vue'
  import { useOss } from '@/components/form/upload/oss'
  import { message } from 'ant-design-vue'
  import { useLocal } from '@/components/form/upload/local'
  import { T } from '@/utils/i18n'

  export default defineComponent({
    name: 'ImageUpload',
    props: {
      beforeUpload: {
        type: Function,
        default: function () {
          return true
        },
      },
      host: {
        type: String,
        default: import.meta.env.VITE_BASE_API + '/file/upload',
      },
      modelValue: {
        type: String,
        default: '',
      },
      type: {
        type: String,
        default: 'local', //local oss
      },
       accept: {
        type: String,
        default: 'image/*'
      }
    },
    components: { PlusOutlined },
    setup (props, context) {
      const fileList = computed({
        get: () => props.modelValue ? [{ uid: '-1', name: props.modelValue, status: 'done', url: props.modelValue }] : [],
        set: (val) => {
          context.emit('update:modelValue', val.length ? val[0].url : '')
        }
      })

      let fileUpload = reactive({
        fileUploadHost: '',
        fileUploadData: {},
        beforeFileUpload: null,
        headers: {},
      })

      if (props.type === 'oss') {
        fileUpload = useOss(props.beforeUpload)
      } else {
        fileUpload = useLocal(props.beforeUpload, props.host)
      }

      const updateValue = (_fileList) => {
        context.emit('update:modelValue', _fileList.length ? _fileList[0].url : '');
      }

      const fileRemove = () => {
        context.emit('update:modelValue', '')
      }

      const onError = () => {
        message.error(T('UploadFailed'))
      }

      const fileUploadSuccess = (response, file, _fileList) => {
        file.url = response?.data?.url || file.url
        updateValue([file])
      }

      const previewVisible = ref(false);
      const previewImage = ref('');
      const previewTitle = ref('');

      const handleCancel = () => {
        previewVisible.value = false;
      };

      const handlePreview = async file => {
        if (!file.url && !file.preview) {
          file.preview = await new Promise(resolve => {
            const reader = new FileReader();
            reader.readAsDataURL(file.originFileObj);
            reader.onload = () => resolve(reader.result);
          });
        }
        previewImage.value = file.url || file.preview;
        previewVisible.value = true;
        previewTitle.value = file.name || file.url.substring(file.url.lastIndexOf('/') + 1);
      };

      return {
        fileList,
        ...toRefs(fileUpload),
        fileRemove,
        onError,
        fileUploadSuccess,
        previewVisible,
        previewImage,
        previewTitle,
        handleCancel,
        handlePreview,
        T
      }
    },
  })
</script>
