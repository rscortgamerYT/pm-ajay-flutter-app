import 'package:flutter/material.dart';

/// Utility class for implementing lazy loading patterns
class LazyLoadingUtils {
  /// Default page size for pagination
  static const int defaultPageSize = 20;
  
  /// Default threshold for triggering next page load (pixels from bottom)
  static const double defaultScrollThreshold = 200.0;

  /// Create a lazy loading scroll controller
  static ScrollController createLazyController({
    required VoidCallback onLoadMore,
    double threshold = defaultScrollThreshold,
  }) {
    final controller = ScrollController();
    
    controller.addListener(() {
      if (controller.position.pixels >= 
          controller.position.maxScrollExtent - threshold) {
        onLoadMore();
      }
    });
    
    return controller;
  }

  /// Check if scroll position is near bottom
  static bool isNearBottom(
    ScrollController controller, {
    double threshold = defaultScrollThreshold,
  }) {
    if (!controller.hasClients) return false;
    return controller.position.pixels >= 
           controller.position.maxScrollExtent - threshold;
  }

  /// Paginate a list into chunks
  static List<List<T>> paginate<T>(
    List<T> items, {
    int pageSize = defaultPageSize,
  }) {
    final pages = <List<T>>[];
    for (var i = 0; i < items.length; i += pageSize) {
      final end = (i + pageSize < items.length) ? i + pageSize : items.length;
      pages.add(items.sublist(i, end));
    }
    return pages;
  }

  /// Get a page of items
  static List<T> getPage<T>(
    List<T> items,
    int page, {
    int pageSize = defaultPageSize,
  }) {
    final start = page * pageSize;
    if (start >= items.length) return [];
    
    final end = start + pageSize;
    return items.sublist(
      start,
      end > items.length ? items.length : end,
    );
  }

  /// Calculate total pages needed
  static int getTotalPages(
    int totalItems, {
    int pageSize = defaultPageSize,
  }) {
    return (totalItems / pageSize).ceil();
  }

  /// Check if there are more pages
  static bool hasMorePages(
    int currentPage,
    int totalItems, {
    int pageSize = defaultPageSize,
  }) {
    return currentPage < getTotalPages(totalItems, pageSize: pageSize) - 1;
  }
}

/// Controller for managing lazy loading state
class LazyLoadingController<T> extends ChangeNotifier {
  LazyLoadingController({
    required this.loadPage,
    this.pageSize = LazyLoadingUtils.defaultPageSize,
    this.initialPage = 0,
  }) {
    _loadInitialPage();
  }

  /// Function to load a page of data
  final Future<List<T>> Function(int page, int pageSize) loadPage;
  
  /// Number of items per page
  final int pageSize;
  
  /// Initial page to load
  final int initialPage;

  /// All loaded items
  final List<T> _items = [];
  List<T> get items => List.unmodifiable(_items);

  /// Current page
  int _currentPage = -1;
  int get currentPage => _currentPage;

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Has more pages
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// Error state
  String? _error;
  String? get error => _error;

  /// Load initial page
  Future<void> _loadInitialPage() async {
    _currentPage = initialPage - 1;
    await loadMore();
  }

  /// Load more items
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newItems = await loadPage(nextPage, pageSize);
      
      _items.addAll(newItems);
      _currentPage = nextPage;
      _hasMore = newItems.length == pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    _items.clear();
    _currentPage = initialPage - 1;
    _hasMore = true;
    _error = null;
    await loadMore();
  }

  /// Clear all data
  void clear() {
    _items.clear();
    _currentPage = initialPage - 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }
}

/// Widget for lazy loading lists
class LazyLoadingListView<T> extends StatefulWidget {
  const LazyLoadingListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.padding,
    this.physics,
  });

  final LazyLoadingController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  State<LazyLoadingListView<T>> createState() => _LazyLoadingListViewState<T>();
}

class _LazyLoadingListViewState<T> extends State<LazyLoadingListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = LazyLoadingUtils.createLazyController(
      onLoadMore: _loadMore,
    );
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _loadMore() {
    if (!widget.controller.isLoading && widget.controller.hasMore) {
      widget.controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.items.isEmpty && !widget.controller.isLoading) {
      if (widget.controller.error != null) {
        return widget.errorBuilder?.call(context, widget.controller.error!) ??
            Center(child: Text('Error: ${widget.controller.error}'));
      }
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items'));
    }

    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: widget.controller.items.length + (widget.controller.hasMore ? 1 : 0),
      separatorBuilder: (context, index) {
        return widget.separatorBuilder?.call(context, index) ?? const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (index >= widget.controller.items.length) {
          return widget.loadingBuilder?.call(context) ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
        }
        
        final item = widget.controller.items[index];
        return widget.itemBuilder(context, item, index);
      },
    );
  }
}

/// Widget for lazy loading grid
class LazyLoadingGridView<T> extends StatefulWidget {
  const LazyLoadingGridView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.padding,
    this.physics,
  });

  final LazyLoadingController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  State<LazyLoadingGridView<T>> createState() => _LazyLoadingGridViewState<T>();
}

class _LazyLoadingGridViewState<T> extends State<LazyLoadingGridView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = LazyLoadingUtils.createLazyController(
      onLoadMore: _loadMore,
    );
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _loadMore() {
    if (!widget.controller.isLoading && widget.controller.hasMore) {
      widget.controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.items.isEmpty && !widget.controller.isLoading) {
      if (widget.controller.error != null) {
        return widget.errorBuilder?.call(context, widget.controller.error!) ??
            Center(child: Text('Error: ${widget.controller.error}'));
      }
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.controller.items.length + (widget.controller.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.controller.items.length) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }
        
        final item = widget.controller.items[index];
        return widget.itemBuilder(context, item, index);
      },
    );
  }
}