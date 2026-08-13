<script setup>
import { useAttrs } from 'vue';
import auremedLogo from 'dashboard/assets/auremed/auremed-logo.png';

const attrs = useAttrs();
</script>

<template>
  <img v-bind="attrs" :src="auremedLogo" alt="Auremed" />
</template>
