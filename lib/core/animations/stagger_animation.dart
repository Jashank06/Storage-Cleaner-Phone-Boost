import 'package:flutter/material.dart';

/// Helper for creating stagger animations on lists
class StaggerAnimation {
  static Widget staggeredList({
    required List<Widget> children,
    int delayMs = 50,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      physics: physics,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return _StaggeredItem(
          index: index,
          delayMs: delayMs,
          child: children[index],
        );
      },
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final int index;
  final int delayMs;
  final Widget child;
  
  const _StaggeredItem({
    required this.index,
    required this.delayMs,
    required this.child,
  });
  
  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    Future.delayed(Duration(milliseconds: widget.index * widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
