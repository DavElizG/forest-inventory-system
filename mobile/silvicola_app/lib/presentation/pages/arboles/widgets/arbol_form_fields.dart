import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de fecha de medición (editable)
class FechaMedicionField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;

  const FechaMedicionField({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: 'Fecha de Medición *',
        hintText: 'Selecciona una fecha',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona la fecha de medición';
        }
        return null;
      },
    );
  }
}

/// Campo de altura total (HT)
class AlturaField extends StatelessWidget {
  final TextEditingController controller;

  const AlturaField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Altura Total - HT (m) *',
        hintText: 'Ej: 15.5',
        prefixIcon: const Icon(Icons.height),
        helperText: 'Altura total del árbol',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa la altura total';
        }
        final altura = double.tryParse(value);
        if (altura == null || altura <= 0) {
          return 'Altura inválida';
        }
        return null;
      },
    );
  }
}

/// Campo de altura comercial (HC)
class AlturaComercialField extends StatelessWidget {
  final TextEditingController controller;

  const AlturaComercialField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Altura Comercial - HC (m)',
        hintText: 'Ej: 12.0',
        prefixIcon: const Icon(Icons.straighten),
        helperText: 'Altura aprovechable del árbol (opcional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final altura = double.tryParse(value);
          if (altura == null || altura <= 0) {
            return 'Altura comercial inválida';
          }
        }
        return null;
      },
    );
  }
}

/// Campo de diámetro (DAP)
class DiametroField extends StatelessWidget {
  final TextEditingController controller;

  const DiametroField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Diámetro DAP (cm) *',
        hintText: 'Ej: 45.2',
        prefixIcon: const Icon(Icons.straighten),
        helperText: 'Diámetro a la altura del pecho (1.3m)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa el diámetro';
        }
        final dap = double.tryParse(value);
        if (dap == null || dap <= 0) {
          return 'Diámetro inválido';
        }
        return null;
      },
    );
  }
}

/// Campo de observaciones
class ObservacionesField extends StatelessWidget {
  final TextEditingController controller;

  const ObservacionesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: 'Observaciones',
        hintText: 'Notas adicionales sobre el árbol',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Campo de latitud
class LatitudField extends StatelessWidget {
  final TextEditingController controller;

  const LatitudField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: 'Latitud *',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa la latitud';
        }
        final lat = double.tryParse(value);
        if (lat == null || lat < -90 || lat > 90) {
          return 'Latitud inválida';
        }
        return null;
      },
    );
  }
}

/// Campo de longitud
class LongitudField extends StatelessWidget {
  final TextEditingController controller;

  const LongitudField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: 'Longitud *',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa la longitud';
        }
        final lon = double.tryParse(value);
        if (lon == null || lon < -180 || lon > 180) {
          return 'Longitud inválida';
        }
        return null;
      },
    );
  }
}
