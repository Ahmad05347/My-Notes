import 'package:flutter/material.dart';
import 'package:my_notes/widgets/colors.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String textType;
  final String hintText;
  final IconData iconName;
  final void Function(String value)? function;
  final String? Function(String?)? validator;
  const MyTextField({
    super.key,
    required this.textType,
    required this.hintText,
    required this.iconName,
    this.function,
    this.validator,
    required this.controller,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: 325,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
        border: Border.all(color: AppColors.primaryFourElementText),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 17),
            width: 16,
            height: 16,
            child: Icon(
              iconName,
            ),
          ),
          SizedBox(
            width: 270,
            height: 50,
            child: TextFormField(
              controller: controller,
              onChanged: (value) => function!(value),
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                hintStyle: const TextStyle(
                  color: AppColors.primarySecondaryElementText,
                ),
              ),
              style: const TextStyle(
                color: AppColors.primaryText,
                fontFamily: "Avenir",
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              autocorrect: false,
              obscureText: obscureText,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
