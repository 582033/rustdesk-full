import Clipboard from 'clipboard'
import { message } from 'ant-design-vue'
import { T } from '@/utils/i18n'

export async function handleClipboard (text) {
  if (navigator.clipboard && navigator.clipboard.writeText) {
    await navigator.clipboard.writeText(text)
  } else {
    // Fallback
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.top = '-9999px'
    textArea.style.left = '-9999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()
    try {
      const successful = document.execCommand('copy')
      if (!successful) {
        throw new Error('Fallback: Unable to copy')
      }
    } finally {
      document.body.removeChild(textArea)
    }
  }
}

export function copyImage (targetNode) {
  if (window.getSelection) {
    // chrome等主流浏览器
    var selection = window.getSelection()
    selection.removeAllRanges()
    var range = document.createRange()
    range.selectNode(targetNode)
    selection.addRange(range)
  } else if (document.body.createTextRange) {
    console.log('IE')
    // ie
    const range = document.body.createTextRange()
    range.moveToElementText(targetNode)
    range.select()
  }
  document.execCommand('copy')
}
