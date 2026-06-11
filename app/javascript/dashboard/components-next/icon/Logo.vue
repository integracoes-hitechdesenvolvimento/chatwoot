<script setup>
import { useAttrs } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import hitechLogoIcon from 'dashboard/assets/hitech/hitech-logo-icon.png';

const attrs = useAttrs();
const globalConfig = useMapGetter('globalConfig/get');
</script>

<template>
  <img
    v-if="globalConfig.logoThumbnail"
    v-bind="attrs"
    :src="globalConfig.logoThumbnail"
    alt="HiTech"
  />
  <img v-else v-bind="attrs" :src="hitechLogoIcon" alt="HiTech" />
</template>
