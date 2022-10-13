import 'package:emoji_picker_flutter/src/icon_data.dart';
import 'package:flutter/cupertino.dart';

/// A class to store data for each individual emoji

enum EmojiType { emoji, icon, image }

extension EmojiTypeEx on EmojiType {
  static EmojiType getValue(String? _) {
    if (_ == null) return EmojiType.emoji;
    return EmojiType.values.firstWhere(
        (e) => e.toString().toLowerCase() == 'EmojiType.$_'.toLowerCase(),
        orElse: () => EmojiType.emoji);
  }

  String get text => toString().split('.').last.toLowerCase();
}

class Emoji<T> {
  /// Emoji constructor
  const Emoji(this.emoji, this.name,
      {this.hasSkinTone = false, this.type = EmojiType.emoji});

  /// The unicode string for this emoji
  ///
  /// This is the string that should be displayed to view the emoji
  final T emoji;

  /// The name or description for this emoji
  final String name;

  /// Flag if emoji supports multiple skin tones
  final bool hasSkinTone;

  final EmojiType type;

  String get displayText {
    switch (type) {
      case EmojiType.emoji:
        return emoji as String;
      case EmojiType.icon:
        return '';
      case EmojiType.image:
        return '';
    }
  }

  int get length {
    return displayText.length;
  }

  List<int> get codeUnits {
    return displayText.codeUnits;
  }

  toItemJson() {
    switch (type) {
      case EmojiType.emoji:
        return emoji as String;
      case EmojiType.icon:
        return (emoji as IconData).toJson();
      case EmojiType.image:
        return '';
    }
  }

  @override
  String toString() {
    return 'Emoji: $emoji, Name: $name, HasSkinTone: $hasSkinTone';
  }

  /// Parse Emoji from json
  static Emoji fromJson(Map<String, dynamic> json) {
    late dynamic emoji;

    final type = EmojiTypeEx.getValue(json['type']);

    switch (type) {
      case EmojiType.emoji:
        emoji = json['emoji'] as String;
        break;
      case EmojiType.icon:
        emoji = IconDataEx.fromJson(json['emoji']);
        break;
      case EmojiType.image:

        /// todo 나중에 변경
        emoji = json['emoji'] as String;
        break;
    }

    return Emoji(
      emoji,
      json['name'] as String,
      type: type,
      hasSkinTone:
          json['hasSkinTone'] != null ? json['hasSkinTone'] as bool : false,
    );
  }

  ///  Encode Emoji to json
  Map<String, dynamic> toJson() {
    return {
      'emoji': toItemJson(),
      'name': name,
      'hasSkinTone': hasSkinTone,
      'type': type.text
    };
  }

  /// Copy method
  Emoji copyWith({String? name, String? emoji, bool? hasSkinTone}) {
    return Emoji(
      emoji ?? this.emoji,
      name ?? this.name,
      hasSkinTone: hasSkinTone ?? this.hasSkinTone,
    );
  }
}
