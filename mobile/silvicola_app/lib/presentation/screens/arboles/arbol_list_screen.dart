import 'package:flutter/material.dart';

import '../../../core/config/router_config.dart' as routes;

class ArbolListScreen extends StatelessWidget {
  const ArbolListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Árboles'),
      ),
      body: const Center(
        child: Text('Lista de árboles - TODO: Implementar'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, routes.AppRoutes.arbolForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
