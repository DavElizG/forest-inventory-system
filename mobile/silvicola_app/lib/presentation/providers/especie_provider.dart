import 'package:flutter/material.dart';

class EspecieProvider extends ChangeNotifier {
  List<dynamic> _especies = [];
  bool _isLoading = false;

  List<dynamic> get especies => _especies;
  bool get isLoading => _isLoading;

  Future<void> fetchEspecies() async {
    _isLoading = true;
    notifyListeners();
    // TODO: Implementar fetch
    _isLoading = false;
    notifyListeners();
  }
}
