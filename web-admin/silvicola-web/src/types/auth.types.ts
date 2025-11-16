export interface User {
  id: number;
  email: string;
  nombre: string;
  rol: 'Admin' | 'Usuario' | 'Visualizador';
  activo: boolean;
  createdAt: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}
