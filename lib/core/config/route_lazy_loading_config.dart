import 'package:flutter/material.dart';

/// Configuration for lazy loading routes and features
class RouteLazyLoadingConfig {
  /// Routes that should be preloaded on app start
  static const List<String> preloadRoutes = [
    '/login',
    '/home',
    '/dashboard',
  ];

  /// Routes that should be loaded on-demand
  static const List<String> lazyRoutes = [
    '/projects',
    '/agencies',
    '/tenders',
    '/reports',
    '/documents',
    '/geofencing',
    '/compliance',
    '/collaboration',
    '/citizen-portal',
    '/settings',
    '/profile',
  ];

  /// Features that should be lazy loaded
  static const Map<String, List<String>> lazyFeatures = {
    'ai': ['ai_service', 'ai_chat', 'ai_analysis'],
    'blockchain': ['blockchain_service', 'smart_contracts'],
    'reporting': ['advanced_charts', 'export_service'],
    'geofencing': ['location_service', 'map_service'],
  };

  /// Check if a route should be preloaded
  static bool shouldPreload(String route) {
    return preloadRoutes.contains(route);
  }

  /// Check if a route should be lazy loaded
  static bool shouldLazyLoad(String route) {
    return lazyRoutes.contains(route);
  }

  /// Get lazy loading priority (lower number = higher priority)
  static int getPriority(String route) {
    final index = lazyRoutes.indexOf(route);
    return index == -1 ? 999 : index;
  }
}

/// Mixin for implementing lazy route loading
mixin LazyRouteMixin {
  final Map<String, Widget Function()> _routeBuilders = {};
  final Set<String> _loadedRoutes = {};

  /// Register a lazy route
  void registerLazyRoute(String route, Widget Function() builder) {
    _routeBuilders[route] = builder;
  }

  /// Check if route is loaded
  bool isRouteLoaded(String route) {
    return _loadedRoutes.contains(route);
  }

  /// Load a route
  Widget loadRoute(String route) {
    if (!_routeBuilders.containsKey(route)) {
      throw Exception('Route $route not registered');
    }

    if (!_loadedRoutes.contains(route)) {
      _loadedRoutes.add(route);
    }

    return _routeBuilders[route]!();
  }

  /// Preload multiple routes
  Future<void> preloadRoutes(List<String> routes) async {
    for (final route in routes) {
      if (_routeBuilders.containsKey(route) && !_loadedRoutes.contains(route)) {
        _loadedRoutes.add(route);
        // Trigger widget creation in next frame
        await Future.microtask(() {});
      }
    }
  }

  /// Clear loaded routes
  void clearLoadedRoutes() {
    _loadedRoutes.clear();
  }

  /// Get loaded routes count
  int getLoadedRoutesCount() {
    return _loadedRoutes.length;
  }
}

/// Widget for lazy loading a page
class LazyLoadPage extends StatefulWidget {
  const LazyLoadPage({
    super.key,
    required this.builder,
    this.placeholder,
    this.onLoad,
  });

  final Future<Widget> Function() builder;
  final Widget? placeholder;
  final VoidCallback? onLoad;

  @override
  State<LazyLoadPage> createState() => _LazyLoadPageState();
}

class _LazyLoadPageState extends State<LazyLoadPage> {
  late Future<Widget> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.builder();
    widget.onLoad?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading page: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _future = widget.builder();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return widget.placeholder ??
              const Center(child: CircularProgressIndicator());
        }

        return snapshot.data!;
      },
    );
  }
}

/// Route builder with lazy loading support
class LazyRouteBuilder {
  final Map<String, WidgetBuilder> _routes = {};
  final Map<String, Future<Widget> Function()> _lazyRoutes = {};

  /// Register a normal route
  void registerRoute(String path, WidgetBuilder builder) {
    _routes[path] = builder;
  }

  /// Register a lazy route
  void registerLazyRoute(String path, Future<Widget> Function() builder) {
    _lazyRoutes[path] = builder;
  }

  /// Generate routes
  Route<dynamic>? generateRoute(RouteSettings settings) {
    final path = settings.name;
    if (path == null) return null;

    // Check normal routes first
    if (_routes.containsKey(path)) {
      return MaterialPageRoute(
        settings: settings,
        builder: _routes[path]!,
      );
    }

    // Check lazy routes
    if (_lazyRoutes.containsKey(path)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => LazyLoadPage(
          builder: _lazyRoutes[path]!,
        ),
      );
    }

    // Route not found
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Route not found: $path'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get all registered routes
  List<String> getAllRoutes() {
    return [..._routes.keys, ..._lazyRoutes.keys];
  }

  /// Check if route exists
  bool hasRoute(String path) {
    return _routes.containsKey(path) || _lazyRoutes.containsKey(path);
  }
}

/// Service for managing code splitting
class CodeSplittingService {
  static final CodeSplittingService _instance = CodeSplittingService._internal();
  factory CodeSplittingService() => _instance;
  CodeSplittingService._internal();

  final Map<String, bool> _loadedChunks = {};
  final Map<String, Future<void>> _pendingLoads = {};

  /// Check if a chunk is loaded
  bool isChunkLoaded(String chunkName) {
    return _loadedChunks[chunkName] ?? false;
  }

  /// Load a code chunk
  Future<void> loadChunk(String chunkName, Future<void> Function() loader) async {
    if (_loadedChunks[chunkName] ?? false) {
      return;
    }

    if (_pendingLoads.containsKey(chunkName)) {
      return _pendingLoads[chunkName];
    }

    final future = loader().then((_) {
      _loadedChunks[chunkName] = true;
      _pendingLoads.remove(chunkName);
    }).catchError((error) {
      _pendingLoads.remove(chunkName);
      throw error;
    });

    _pendingLoads[chunkName] = future;
    return future;
  }

  /// Preload multiple chunks
  Future<void> preloadChunks(Map<String, Future<void> Function()> chunks) async {
    await Future.wait(
      chunks.entries.map((entry) => loadChunk(entry.key, entry.value)),
    );
  }

  /// Get loading statistics
  Map<String, dynamic> getStats() {
    return {
      'loadedChunks': _loadedChunks.length,
      'pendingLoads': _pendingLoads.length,
      'chunks': _loadedChunks.keys.toList(),
    };
  }

  /// Clear loaded chunks
  void clearChunks() {
    _loadedChunks.clear();
    _pendingLoads.clear();
  }
}

/// Widget for conditionally loading features
class ConditionalFeature extends StatefulWidget {
  const ConditionalFeature({
    super.key,
    required this.featureName,
    required this.loader,
    required this.child,
    this.placeholder,
  });

  final String featureName;
  final Future<void> Function() loader;
  final Widget child;
  final Widget? placeholder;

  @override
  State<ConditionalFeature> createState() => _ConditionalFeatureState();
}

class _ConditionalFeatureState extends State<ConditionalFeature> {
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeature();
  }

  Future<void> _loadFeature() async {
    final service = CodeSplittingService();
    
    if (service.isChunkLoaded(widget.featureName)) {
      setState(() => _isLoaded = true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await service.loadChunk(widget.featureName, widget.loader);
      if (mounted) {
        setState(() {
          _isLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load feature: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _loadFeature();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isLoaded) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    return widget.child;
  }
}