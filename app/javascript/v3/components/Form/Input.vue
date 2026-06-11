<script setup>
import { defineProps, defineModel, computed } from 'vue';
import { useToggle } from '@vueuse/core';

import Button from 'dashboard/components-next/button/Button.vue';
import WithLabel from './WithLabel.vue';

const props = defineProps({
  label: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    default: 'text',
  },
  icon: {
    type: String,
    default: '',
  },
  name: {
    type: String,
    required: true,
  },
  hasError: Boolean,
  errorMessage: {
    type: String,
    default: '',
  },
  spacing: {
    type: String,
    default: 'base',
    validator: value => ['base', 'compact'].includes(value),
  },
  variant: {
    type: String,
    default: 'default',
    validator: value => ['default', 'nexus'].includes(value),
  },
});

const FIELDS = {
  TEXT: 'text',
  PASSWORD: 'password',
};

defineOptions({
  inheritAttrs: false,
});

const model = defineModel({
  type: [String, Number],
  required: true,
});

const [isPasswordVisible, togglePasswordVisibility] = useToggle();

const isPasswordField = computed(() => props.type === FIELDS.PASSWORD);

const currentInputType = computed(() => {
  if (isPasswordField.value) {
    return isPasswordVisible.value ? FIELDS.TEXT : FIELDS.PASSWORD;
  }
  return props.type;
});

const isNexusVariant = computed(() => props.variant === 'nexus');
</script>

<template>
  <WithLabel
    :label="label"
    :icon="icon"
    :name="name"
    :has-error="hasError"
    :error-message="errorMessage"
    :variant="variant"
  >
    <template #rightOfLabel>
      <slot />
    </template>
    <input
      v-bind="$attrs"
      v-model="model"
      :name="name"
      :type="currentInputType"
      class="block w-full appearance-none sm:text-sm sm:leading-6"
      :class="{
        'rounded-xl border bg-slate-950/60 px-3 py-3.5 text-slate-100 shadow-none outline-none placeholder:text-slate-500 focus:border-blue-500/50 focus:ring-2 focus:ring-blue-500/20':
          isNexusVariant,
        'border-none rounded-md shadow-sm bg-n-alpha-black2 outline outline-1 focus:outline focus:outline-1 text-n-slate-12 placeholder:text-n-slate-10':
          !isNexusVariant,
        'border-red-500/60 focus:border-red-500/60 focus:ring-red-500/20': isNexusVariant && hasError,
        'border-slate-700/90': isNexusVariant && !hasError,
        'error outline-n-ruby-8 dark:outline-n-ruby-8 hover:outline-n-ruby-9 dark:hover:outline-n-ruby-9 disabled:outline-n-ruby-8 dark:disabled:outline-n-ruby-8':
          !isNexusVariant && hasError,
        'outline-n-weak dark:outline-n-weak hover:outline-n-slate-6 dark:hover:outline-n-slate-6 focus:outline-n-brand dark:focus:outline-n-brand':
          !isNexusVariant && !hasError,
        'px-3 py-3': spacing === 'base' && !isNexusVariant,
        'px-3 py-2 mb-0': spacing === 'compact',
        'pl-10': icon && isNexusVariant,
        'pl-9': icon && !isNexusVariant,
        'pr-10': isPasswordField,
      }"
    />
    <Button
      v-if="isPasswordField"
      type="button"
      slate
      sm
      link
      :icon="isPasswordVisible ? 'i-lucide-eye-off' : 'i-lucide-eye'"
      class="absolute inset-y-0 right-0 pr-3"
      :class="{ '!text-slate-400 hover:!text-slate-300': isNexusVariant }"
      :aria-label="isPasswordVisible ? 'Hide password' : 'Show password'"
      :aria-pressed="isPasswordVisible"
      @click="togglePasswordVisibility()"
    />
  </WithLabel>
</template>
