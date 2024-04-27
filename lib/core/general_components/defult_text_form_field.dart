import 'package:flutter/material.dart';

Widget defaultTextFormFelid({
  required TextEditingController controller,
  required String text,
  required Icon prefixIcon,
  required Color fillColor,
  Function? onChange,
  bool? enabled,
  bool? border,
}) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: TextFormField(
      style: TextStyle(color: fillColor),
      controller: controller,
      enabled: enabled ?? true,
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Please enter $text";
        }
        return null;
      },
      onChanged: (value) {
        if (onChange != null) {
          onChange.call(value);
        }
      },
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: text,
        labelStyle: TextStyle(color: fillColor),
        prefixIcon: prefixIcon,
      ),
    ),
  );
}
