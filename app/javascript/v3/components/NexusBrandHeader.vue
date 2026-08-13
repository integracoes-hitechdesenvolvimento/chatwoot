<script setup>
import auremedLogo from 'dashboard/assets/auremed/auremed-logo.png';

defineProps({
  brandName: {
    type: String,
    required: true,
  },
  subtitle: {
    type: String,
    required: true,
  },
});
</script>

<template>
  <header class="flex flex-col items-center text-center">
    <img
      :src="auremedLogo"
      :alt="brandName"
      class="h-28 w-auto object-contain sm:h-32"
    />
    <p
      class="mt-4 max-w-xs text-sm font-extralight leading-relaxed tracking-[0.06em] text-white/70 sm:max-w-sm sm:text-[0.95rem]"
    >
      {{ subtitle }}
    </p>
  </header>
</template>
