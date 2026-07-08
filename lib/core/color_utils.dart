import 'package:flutter/material.dart';

Color? colorFromHex(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) {
    return null;
  }

  final value = int.tryParse('FF${hex.substring(1)}', radix: 16);
  return value == null ? null : Color(value);
}
