import 'package:flutter/material.dart';

class MenuItem {
  final String label;
  final VoidCallback onTap;
  
  MenuItem({required this.label, required this.onTap});
}

class VerticalNavMenu extends StatefulWidget {
  final List<MenuItem> menuItems;
  final Color activeColor;
  final int currentIndex;
  
  const VerticalNavMenu({
    super.key,
    required this.menuItems,
    this.activeColor = const Color(0xFFFF6900),
    this.currentIndex = 0,
  });

  @override
  State<VerticalNavMenu> createState() => _VerticalNavMenuState();
}

class _VerticalNavMenuState extends State<VerticalNavMenu> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.menuItems.length, (index) {
          final item = widget.menuItems[index];
          final isHovered = _hoveredIndex == index;
          final isActive = widget.currentIndex == index;
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated arrow
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: (isHovered || isActive) ? 40 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: (isHovered || isActive) ? 1.0 : 0.0,
                        child: Icon(
                          Icons.arrow_forward,
                          color: widget.activeColor,
                          size: 40,
                        ),
                      ),
                    ),
                    
                    // Menu label with slide animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      transform: Matrix4.identity()
                        ..translate((isHovered || isActive) ? 0.0 : -40.0, 0.0)
                        ..rotateZ((isHovered || isActive) ? 0.0 : 0.0),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: (isHovered || isActive) 
                              ? widget.activeColor 
                              : (Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black87),
                        ),
                        child: Text(item.label),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}