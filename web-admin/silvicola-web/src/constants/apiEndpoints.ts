export const API_ENDPOINTS = {
  // Auth
  LOGIN: '/auth/login',
  LOGOUT: '/auth/logout',
  CHANGE_PASSWORD: '/auth/change-password',

  // Arboles
  ARBOLES: '/arboles',
  ARBOL_BY_ID: (id: number) => `/arboles/${id}`,

  // Parcelas
  PARCELAS: '/parcelas',
  PARCELA_BY_ID: (id: number) => `/parcelas/${id}`,

  // Especies
  ESPECIES: '/especies',
  ESPECIE_BY_ID: (id: number) => `/especies/${id}`,

  // Usuarios
  USUARIOS: '/usuarios',
  USUARIO_BY_ID: (id: number) => `/usuarios/${id}`,

  // Reportes
  REPORTE_EXCEL: '/reportes/excel',
  REPORTE_KMZ: '/reportes/kmz',
} as const;
