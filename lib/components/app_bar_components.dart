import 'package:flutter/material.dart';

class AppbarButtons extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const AppbarButtons({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.grey.shade400,
          ),
        ),
        child: Icon(icon),
      ),
    );
  }
}
