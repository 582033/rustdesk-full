<template>
  <div class="upload-order-file">
    <a-upload
        ref="upload"
        :before-upload="beforeFileUpload"
        :on-success="fileUploadSuccess"
        :on-remove="fileRemove"
        :on-exceed="onExceed"
        :on-error="onError"
        name="file"
        :multiple="multiple"
        :file-list="fileList"
        :action="fileUploadHost"
        :data="fileUploadData"
        :headers="headers"
        list-type="picture-card"
        :accept="accept"
        @preview="handlePreview"
    >
      <div v-if="fileList.length < limit">
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
  import { PlusOutlined, ArrowLeftOutlined, ArrowRightOutlined, DeleteOutlined, CheckOutlined } from '@ant-design/icons-vue'
  import { useOss } from '@/components/form/upload/oss'
  import { message } from 'ant-design-vue'
  import { useLocal } from '@/components/form/upload/local'
  import { T } from '@/utils/i18n'

  export default defineComponent({
    name: 'ImagesUpload',
    props: {
      limit: {
        type: Number,
        default: 1,
      },
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
        type: Array,
        default: function () {
          return []
        },
      },
      type: {
        type: String,
        default: 'local', //local oss
      },
      multiple: {
        type: Boolean,
        default: false,
      },
      accept: {
        type: String,
        default: 'image/*'
      }
    },
    components: { PlusOutlined, ArrowLeftOutlined, ArrowRightOutlined, DeleteOutlined, CheckOutlined },
    setup (props, context) {
      const fileList = computed({
        get: () => props.modelValue.map((url, index) => ({ uid: -index, name: url, status: 'done', url })),
        set: (val) => {
          context.emit('update:modelValue', val.map(file => file.url))
        }
      })

      let fileUpload = reactive({
        fileUploadHost: '',
        fileUploadData: {},
        beforeFileUpload: null,
        headers: {},
      })

      if (props.type === 'oss') {
        fileUpload = useOss(props.beforeUpload, props.multiple)
      } else {
        fileUpload = useLocal(props.beforeUpload, props.host)
      }
      
      const updateValue = (_fileList) => {
        context.emit('update:modelValue', _fileList.filter(f => f.status === 'done').map(file => file.url));
      }

      const fileRemove = (file) => {
        const newFileList = fileList.value.filter(f => f.uid !== file.uid)
        fileList.value = newFileList
      }

      const onError = () => {
        message.error(T('UploadFailed'))
      }

      const fileUploadSuccess = (response, file, _fileList) => {
        file.url = response?.data?.url || file.url
        if (_fileList.every(f => f.status === 'done')) {
          updateValue(_fileList)
        }
      }

      const onExceed = () => {
        message.error(`最多上传 ${props.limit} 张图片`)
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
        onExceed,
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
