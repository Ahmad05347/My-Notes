import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

myButton(String text, Color color, void Function()? onTap, Color textColor) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 130,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ),
    ),
  );
}
