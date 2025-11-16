export interface Arbol {
  id: number;
  codigo: string;
  especieId: number;
  parcelaId: number;
  dap: number;
  altura: number;
  latitud: number;
  longitud: number;
  fotoPath?: string;
  observaciones?: string;
  estado: 'Vivo' | 'Muerto' | 'Enfermo';
  fechaMedicion: string;
  createdAt: string;
  updatedAt: string;
}

export interface ArbolCreateDto {
  codigo: string;
  especieId: number;
  parcelaId: number;
  dap: number;
  altura: number;
  latitud: number;
  longitud: number;
  fotoPath?: string;
  observaciones?: string;
  estado: string;
  fechaMedicion: string;
}
