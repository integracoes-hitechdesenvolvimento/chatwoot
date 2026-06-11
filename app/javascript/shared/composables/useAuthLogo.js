import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import hitechLogo from 'dashboard/assets/hitech/hitech-logo.png';

const LEGACY_LOGO_MARKERS = [
  '/brand-assets/logo.svg',
  '/brand-assets/logo_dark.svg',
  '/brand-assets/logo_thumbnail.svg',
];

const isLegacyLogo = logo =>
  !logo || LEGACY_LOGO_MARKERS.some(marker => logo.includes(marker));

export function useAuthLogo() {
  const globalConfig = useMapGetter('globalConfig/get');

  const authLogo = computed(() =>
    isLegacyLogo(globalConfig.value?.logo) ? hitechLogo : globalConfig.value.logo
  );

  const authLogoDark = computed(() => {
    const logoDark = globalConfig.value?.logoDark;
    return isLegacyLogo(logoDark) ? hitechLogo : logoDark;
  });

  const installationName = computed(
    () =>
      globalConfig.value?.installationName ||
      'Hi Tech Desenvolvimento - Portal de Atendimentos'
  );

  return {
    authLogo,
    authLogoDark,
    installationName,
  };
}
