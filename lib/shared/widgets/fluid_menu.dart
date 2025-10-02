import 'package:flutter/material.dart';

class FluidMenu extends StatefulWidget {
  final List<FluidMenuItem> items;
  
  const FluidMenu({
    super.key,
    required this.items,
  });

  @override
  State<FluidMenu> createState() => _FluidMenuState();
}

class _FluidMenuState extends State<FluidMenu> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late List<Animation<double>> _itemAnimations;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create animations for each item
    _itemAnimations = List.generate(
      widget.items.length - 1,
      (index) => Tween<double>(
        begin: 0.0,
        end: (index + 1) * 48.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Rotation animation for the toggle icon
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);

    return SizedBox(
      width: 64,
      height: _isExpanded ? 64 + (widget.items.length - 1) * 48 : 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // First item - always visible (toggle button)
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: widget.items[0].icon,
                  ),
                ),
              ),
            ),
          ),
          
          // Other menu items - only visible when expanded
          if (_isExpanded)
            ...List.generate(
              widget.items.length - 1,
              (index) => AnimatedBuilder(
                animation: _itemAnimations[index],
                builder: (context, child) {
                  return Positioned(
                    top: _itemAnimations[index].value,
                    left: 0,
                    child: Opacity(
                      opacity: _controller.value,
                      child: GestureDetector(
                        onTap: () {
                          widget.items[index + 1].onTap?.call();
                          _toggle();
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: widget.items[index + 1].icon,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class FluidMenuItem {
  final Widget icon;
  final VoidCallback? onTap;
  final bool isActive;

  const FluidMenuItem({
    required this.icon,
    this.onTap,
    this.isActive = false,
  });
}