import 'package:flutter/material.dart';

/// Widget de dropdown con búsqueda integrada
class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? selectedValue;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) displayText;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool isLoading;

  const SearchableDropdown({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.selectedValue,
    required this.items,
    required this.displayText,
    required this.onChanged,
    this.validator,
    this.isLoading = false,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.items.firstWhere(
      (item) => item['id'] == widget.selectedValue,
      orElse: () => {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.isLoading ? null : () => _showSearchDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _errorText,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            child: widget.isLoading
                ? const Text('Cargando...')
                : Text(
                    selectedItem.isNotEmpty
                        ? widget.displayText(selectedItem)
                        : widget.hint ?? 'Seleccionar...',
                    style: TextStyle(
                      color: selectedItem.isEmpty ? Colors.grey[600] : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _SearchDialog(
        title: widget.label,
        items: widget.items,
        displayText: widget.displayText,
        selectedValue: widget.selectedValue,
      ),
    );

    if (result != null) {
      widget.onChanged(result);
      // Validar después de seleccionar
      if (widget.validator != null) {
        setState(() {
          _errorText = widget.validator!(result);
        });
      }
    }
  }

  /// Método para validar externamente
  String? validate() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.selectedValue);
      setState(() {
        _errorText = error;
      });
      return error;
    }
    return null;
  }
}

class _SearchDialog extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) displayText;
  final String? selectedValue;

  const _SearchDialog({
    required this.title,
    required this.items,
    required this.displayText,
    this.selectedValue,
  });

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final text = widget.displayText(item).toLowerCase();
          return text.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Título
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Buscar ${widget.title}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo de búsqueda
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterItems('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterItems,
            ),
            const SizedBox(height: 16),

            // Resultados
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item['id'] == widget.selectedValue;

                        return ListTile(
                          title: Text(
                            widget.displayText(item),
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : null,
                              color: isSelected ? Theme.of(context).primaryColor : null,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context, item['id'] as String);
                          },
                        );
                      },
                    ),
            ),

            // Contador de resultados
            if (_filteredItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_filteredItems.length} de ${widget.items.length} resultados',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
