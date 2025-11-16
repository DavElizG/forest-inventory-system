import 'package:flutter/material.dart';

class ParcelaProvider extends ChangeNotifier {
  List<dynamic> _parcelas = [];
  bool _isLoading = false;

  List<dynamic> get parcelas => _parcelas;
  bool get isLoading => _isLoading;

  Future<void> fetchParcelas() async {
    _isLoading = true;
    notifyListeners();
    // TODO: Implementar fetch
    _isLoading = false;
    notifyListeners();
  }
}
