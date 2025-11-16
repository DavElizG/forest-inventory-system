import 'package:flutter/material.dart';

import '../../../core/config/router_config.dart';

class ArbolListScreen extends StatelessWidget {
  const ArbolListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Árboles'),
      ),
      body: Center(
        child: const Text('Lista de árboles - TODO: Implementar'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RouterConfig.arbolForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
