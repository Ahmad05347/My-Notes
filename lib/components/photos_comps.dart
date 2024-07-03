import 'package:flutter/material.dart';

class PhotosComponents extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  const PhotosComponents({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.grey.shade400,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
