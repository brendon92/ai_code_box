import 'package:flutter/material.dart';

class FloatingNavbar extends StatefulWidget {
  const FloatingNavbar({super.key});

  @override
  State<FloatingNavbar> createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Column(
            children: [
              _buildNavItem(Icons.home, 'Home', () {}),
              const SizedBox(height: 10),
              _buildNavItem(Icons.settings, 'Settings', () {}),
              const SizedBox(height: 10),
              _buildNavItem(Icons.person, 'Profile', () {}),
              const SizedBox(height: 10),
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          child: Icon(_isExpanded ? Icons.close : Icons.menu),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        FloatingActionButton.small(
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    );
  }
}
