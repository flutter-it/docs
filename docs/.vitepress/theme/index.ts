import DefaultTheme from 'vitepress/theme'
import { h } from 'vue'
import ConsultingBanner from './ConsultingBanner.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'layout-top': () => h(ConsultingBanner),
    })
  },
}
