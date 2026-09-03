import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget appTextField({
  required TextEditingController controller,
  required String hintText,
  required VoidCallback onPressed,
  bool? isLoading,
  Iterable<String>? autofillHints,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? textInputType,
  bool? obscureText,
  String? Function(String?)? validator,
  Widget? prefix,
  Widget? suffix,
}) {
  var border = OutlineInputBorder(
    borderSide: .none,
    borderRadius: BorderRadius.circular(12),
  );
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: border,
      prefix: prefix,
      isDense: true,
      suffix: suffix,
      hintText: hintText,
      filled: true,
    ),

    autofillHints: autofillHints,
    inputFormatters: inputFormatters,
    keyboardType: textInputType,
    obscureText: obscureText ?? false,
    readOnly: isLoading == true,
    validator: validator,
  );
}
