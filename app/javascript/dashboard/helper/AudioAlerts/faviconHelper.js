const auremedFaviconBySize = {
  '16x16': '/brand-assets/auremed-favicon-16.png',
  '32x32': '/brand-assets/auremed-favicon-32.png',
  '96x96': '/brand-assets/auremed-favicon-96.png',
};

export const showBadgeOnFavicon = () => {
  const favicons = document.querySelectorAll('.favicon');

  favicons.forEach(favicon => {
    const size = favicon.sizes[[0]];
    favicon.href = `/favicon-badge-${size}.png`;
  });
};

export const initFaviconSwitcher = () => {
  const favicons = document.querySelectorAll('.favicon');

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      favicons.forEach(favicon => {
        const size = favicon.sizes[[0]];
        favicon.href =
          auremedFaviconBySize[size] || `/favicon-${size}.png`;
      });
    }
  });
};
