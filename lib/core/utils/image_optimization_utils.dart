import 'dart:async';
import 'package:flutter/material.dart';

/// Utility class for optimizing image loading and caching
class ImageOptimizationUtils {
  static final Map<String, ImageProvider> _imageCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(hours: 24);

  /// Get optimized image provider with caching
  static ImageProvider getOptimizedImage(
    String url, {
    int? cacheWidth,
    int? cacheHeight,
    bool useCache = true,
  }) {
    if (useCache && _imageCache.containsKey(url)) {
      final timestamp = _cacheTimestamps[url];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _cacheDuration) {
        return _imageCache[url]!;
      }
    }

    ImageProvider provider;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      provider = NetworkImage(url);
    } else if (url.startsWith('assets/')) {
      provider = AssetImage(url);
    } else {
      provider = AssetImage(url);
    }

    if (useCache) {
      _imageCache[url] = provider;
      _cacheTimestamps[url] = DateTime.now();
    }

    return provider;
  }

  /// Preload images for better performance
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls, {
    int? cacheWidth,
    int? cacheHeight,
  }) async {
    final futures = imageUrls.map((url) {
      final provider = getOptimizedImage(
        url,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
      return precacheImage(provider, context);
    });

    await Future.wait(futures);
  }

  /// Clear image cache
  static void clearCache() {
    _imageCache.clear();
    _cacheTimestamps.clear();
  }

  /// Clear expired cache entries
  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheDuration) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _imageCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Get cache size
  static int getCacheSize() {
    return _imageCache.length;
  }

  /// Get optimized image dimensions for different screen sizes
  static Size getOptimizedDimensions(
    BuildContext context,
    double aspectRatio, {
    double maxWidth = 1200,
    double maxHeight = 1200,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    double width = screenWidth;
    if (width > maxWidth) width = maxWidth;
    
    double height = width / aspectRatio;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }

    return Size(width, height);
  }
}

/// Widget for optimized image loading with placeholder and error handling
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
    this.useCache = true,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool useCache;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: ImageOptimizationUtils.getOptimizedImage(
        imageUrl,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        useCache: useCache,
      ),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ??
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            );
      },
    );
  }
}

/// Widget for progressive image loading
class ProgressiveImage extends StatefulWidget {
  const ProgressiveImage({
    super.key,
    required this.placeholder,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  final String placeholder;
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration fadeDuration;

  @override
  State<ProgressiveImage> createState() => _ProgressiveImageState();
}

class _ProgressiveImageState extends State<ProgressiveImage> {
  bool _isLoading = true;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ProgressiveImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);
    
    _imageProvider = ImageOptimizationUtils.getOptimizedImage(widget.image);
    
    final imageStream = _imageProvider!.resolve(const ImageConfiguration());
    final completer = Completer<void>();
    
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete();
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(exception, stackTrace);
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
    );
    
    imageStream.addListener(listener);
    
    try {
      await completer.future;
    } finally {
      imageStream.removeListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.fadeDuration,
      child: _isLoading
          ? OptimizedImage(
              key: ValueKey('placeholder_${widget.placeholder}'),
              imageUrl: widget.placeholder,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            )
          : OptimizedImage(
              key: ValueKey('image_${widget.image}'),
              imageUrl: widget.image,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            ),
    );
  }
}

/// Widget for lazy loading images when they come into viewport
class LazyImage extends StatefulWidget {
  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _shouldLoad = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.imageUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0 && !_shouldLoad) {
          setState(() => _shouldLoad = true);
        }
      },
      child: _shouldLoad
          ? OptimizedImage(
              imageUrl: widget.imageUrl,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              placeholder: widget.placeholder,
              errorWidget: widget.errorWidget,
            )
          : widget.placeholder ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
              ),
    );
  }
}

/// Simple visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    // Simplified visibility check - assumes visible
    widget.onVisibilityChanged(
      VisibilityInfo(visibleFraction: 1.0, size: Size.zero),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Visibility information
class VisibilityInfo {
  final double visibleFraction;
  final Size size;

  VisibilityInfo({
    required this.visibleFraction,
    required this.size,
  });
}