<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useData } from 'vitepress'

const dismissed = ref(false)
const banner = ref(null)

// VitePress's fixed nav (and sidebar/content offsets) read
// --vp-layout-top-height to make room for layout-top content; without it
// the nav paints over the banner at top: 0.
function syncLayoutTopHeight() {
  const height = !dismissed.value && banner.value ? banner.value.offsetHeight : 0
  document.documentElement.style.setProperty('--vp-layout-top-height', `${height}px`)
}

onMounted(() => {
  dismissed.value = localStorage.getItem('consulting-banner-dismissed') === '1'
  nextTick(syncLayoutTopHeight)
  window.addEventListener('resize', syncLayoutTopHeight)
})

onUnmounted(() => {
  window.removeEventListener('resize', syncLayoutTopHeight)
  document.documentElement.style.removeProperty('--vp-layout-top-height')
})

const { lang } = useData()
const isEs = computed(() => lang.value.startsWith('es'))

function dismiss() {
  dismissed.value = true
  localStorage.setItem('consulting-banner-dismissed', '1')
  syncLayoutTopHeight()
}
</script>

<template>
  <div v-if="!dismissed" ref="banner" class="consulting-banner">
    <span class="consulting-banner-dot"></span>
    <span class="consulting-banner-text">
      {{ isEs
        ? 'El autor está disponible para consultoría y trabajo por contrato'
        : 'The author is available for consulting & contract work' }}
    </span>
    <a
      class="consulting-banner-link"
      href="https://calendly.com/burkhartsengineering/30min"
      target="_blank"
      rel="noopener"
    >
      {{ isEs ? 'Agenda una llamada →' : 'Book a call →' }}
    </a>
    <button class="consulting-banner-close" aria-label="Dismiss" @click="dismiss">✕</button>
  </div>
</template>
