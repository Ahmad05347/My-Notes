import 'package:flutter/material.dart';

class FormWidget extends StatelessWidget {
  final double? fontSize;
  final int? maxLines;
  final TextEditingController controller;
  final String hintText;

  const FormWidget({
    super.key,
    this.fontSize,
    this.maxLines,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    return TextFormField(
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize,
      ),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
      ),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      keyboardType: TextInputType.multiline,
    );
  }
}
