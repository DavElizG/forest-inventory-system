# Tipos Compartidos - Forest Inventory System

Esta carpeta contiene tipos y definiciones compartidas entre el frontend móvil (Flutter) y el web admin (React).

## Propósito

Mantener la consistencia de tipos entre:
- **Mobile** (Dart): `mobile/silvicola_app/lib/data/models/`
- **Web Admin** (TypeScript): `web-admin/silvicola-web/src/types/`

## Estructura

```
shared/types/
├── README.md
├── arbol.schema.json          # Esquema de árbol
├── parcela.schema.json        # Esquema de parcela
├── especie.schema.json        # Esquema de especie
├── usuario.schema.json        # Esquema de usuario
└── api-responses.schema.json  # Esquemas de respuestas API
```

## Uso

### Generar tipos TypeScript

```bash
# Instalar json-schema-to-typescript globalmente
npm install -g json-schema-to-typescript

# Generar tipos
json2ts shared/types/*.schema.json -o web-admin/silvicola-web/src/types/
```

### Generar tipos Dart

```bash
# Usar quicktype para Dart
quicktype shared/types/*.schema.json -o mobile/silvicola_app/lib/data/models/ --lang dart
```

## Convenciones

- Usar camelCase para propiedades
- Incluir descripciones en los esquemas
- Mantener sincronizados con el backend (.NET)
- Versionar cambios en schemas

## Sincronización

Los schemas deben reflejar los DTOs del backend:
- `ArbolResponseDto` → `arbol.schema.json`
- `ParcelaResponseDto` → `parcela.schema.json`
- `EspecieResponseDto` → `especie.schema.json`
- `UsuarioResponseDto` → `usuario.schema.json`

## Ejemplo de Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Arbol",
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "format": "uuid"
    },
    "codigo": {
      "type": "string"
    },
    "dap": {
      "type": "number",
      "description": "Diámetro a la altura del pecho en cm"
    }
  },
  "required": ["id", "codigo", "dap"]
}
```

---

**Nota**: Los schemas serán creados una vez que los DTOs del backend estén completamente definidos.
