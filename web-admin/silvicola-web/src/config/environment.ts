export const environment = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api',
  apiTimeout: parseInt(import.meta.env.VITE_API_TIMEOUT || '30000'),
  isDevelopment: import.meta.env.VITE_ENVIRONMENT === 'development',
  isProduction: import.meta.env.VITE_ENVIRONMENT === 'production',
  map: {
    defaultCenter: {
      lat: parseFloat(import.meta.env.VITE_MAP_DEFAULT_CENTER_LAT || '4.7110'),
      lng: parseFloat(import.meta.env.VITE_MAP_DEFAULT_CENTER_LNG || '-74.0721'),
    },
    defaultZoom: parseInt(import.meta.env.VITE_MAP_DEFAULT_ZOOM || '6'),
  },
};
