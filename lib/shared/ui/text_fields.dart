import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xorr/shared/theme/app_fonts.dart';

Widget appTextField({
  required TextEditingController controller,
  required String hintText,
  bool? isLoading,
  Iterable<String>? autofillHints,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? textInputType,
  bool? obscureText,
  String? Function(String?)? validator,
  Widget? prefix,
  Widget? suffix,
  AutovalidateMode? autovalidateMode
}) {
  var border = OutlineInputBorder(
    borderSide: .none,
    borderRadius: BorderRadius.circular(5),
  );
  return TextFormField(
    autovalidateMode:autovalidateMode?? .onUserInteraction ,
    controller: controller,
    style: TextStyle(fontFamily: AppFonts.geist),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: border,
      prefixIcon: prefix,
      isDense: true,
      prefixIconConstraints: BoxConstraints(minHeight: 40, minWidth: 40),
      suffixIconConstraints: BoxConstraints(minHeight: 40, minWidth: 40),

      suffixIcon: suffix,
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
