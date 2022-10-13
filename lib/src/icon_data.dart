import 'dart:convert';

import 'package:flutter/widgets.dart';

extension IconDataEx on IconData {
  String get string {
    return json.encode({
      'codePoint': codePoint,
      'fontFamily': fontFamily,
      'fontPackage': fontPackage
    });
  }

  Map<String, dynamic> toJson() => {
        'codePoint': codePoint,
        'fontPackage': fontPackage,
        'fontFamily': fontFamily
      };

  static IconData fromJson(data) {
    return IconData(data['codePoint'],
        fontFamily: data['fontFamily'], fontPackage: data['fontPackage']);
  }
}
