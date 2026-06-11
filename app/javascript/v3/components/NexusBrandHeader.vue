<script setup>
import nexusNMark from 'dashboard/assets/nexus/nexus-n-mark.svg';

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
      :src="nexusNMark"
      alt=""
      class="h-14 w-14 sm:h-16 sm:w-16"
      aria-hidden="true"
    />

    <h1
      class="mt-5 text-[2.75rem] font-bold leading-none tracking-[0.34em] text-white sm:mt-6 sm:text-5xl sm:tracking-[0.38em]"
    >
      {{ brandName }}
    </h1>
    <p
      class="mt-4 max-w-xs text-sm font-extralight leading-relaxed tracking-[0.06em] text-white/75 sm:max-w-sm sm:text-[0.95rem]"
    >
      {{ subtitle }}
    </p>
  </header>
</template>
