import 'package:flutter/material.dart';
import '../../core/constants/performance_constants.dart';

/// Widget optimizado para listas grandes con lazy loading
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyWidget,
    this.controller,
    this.padding,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) return;

    final threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  widget.emptyMessage ?? 'No hay elementos',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(8),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      // Optimización: altura estimada para mejor rendimiento
      itemExtent: PerformanceConstants.listItemHeight,
      // Optimización: mantener items vivos cerca del viewport
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      cacheExtent: PerformanceConstants.listItemHeight * 5,
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          final item = widget.items[index];
          return RepaintBoundary(
            key: ValueKey(index),
            child: widget.itemBuilder(context, item),
          );
        }

        // Loading indicator al final
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

/// Widget para elementos de lista con animaciones suaves
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PerformanceConstants.animationDuration,
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: child,
          ),
        ),
      ),
    );
  }
}
