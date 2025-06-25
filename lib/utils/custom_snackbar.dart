import 'package:flutter/material.dart';

enum SnackBarPosition { top, bottom }

class CustomSnackBar {
  static OverlayEntry? _currentOverlay;
  
  static void show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 1500),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    // Remove any existing snackbar
    _currentOverlay?.remove();
    _currentOverlay = null;
    
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _SnackBarOverlay(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        position: position,
        duration: duration,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );
    
    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
    
    // Auto dismiss is now handled by the overlay widget itself
  }
  
  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFFFF4444),
      icon: Icons.error_outline,
    );
  }
  
  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFF4CAF50),
      icon: Icons.check_circle_outline,
    );
  }
  
  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFF2196F3),
      icon: Icons.info_outline,
    );
  }
}

class _SnackBarOverlay extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final SnackBarPosition position;
  final Duration duration;
  final VoidCallback onDismiss;
  
  const _SnackBarOverlay({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    required this.position,
    required this.duration,
    required this.onDismiss,
  });
  
  @override
  State<_SnackBarOverlay> createState() => _SnackBarOverlayState();
}

class _SnackBarOverlayState extends State<_SnackBarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isRemoving = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    final beginOffset = widget.position == SnackBarPosition.top 
        ? const Offset(0, -1) 
        : const Offset(0, 1);
    
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
    
    // Auto dismiss with fade out animation
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted && !_isRemoving) {
        _dismiss();
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
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    
    final isTop = widget.position == SnackBarPosition.top;
    
    return Positioned(
      top: isTop ? topPadding + 16 : null,
      bottom: isTop ? null : bottomPadding + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (isTop && details.delta.dy < -5) {
              _dismiss();
            } else if (!isTop && details.delta.dy > 5) {
              _dismiss();
            }
          },
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _dismiss() {
    if (_isRemoving) return;
    _isRemoving = true;
    
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }
}