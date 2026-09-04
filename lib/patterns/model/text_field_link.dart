
import 'package:flutter/foundation.dart';

@immutable
class TextFieldLink {
  final String fromId;
  final String toId;

  const TextFieldLink({
    required this.fromId,
    required this.toId,
  });

  TextFieldLink copyWith({
    String? fromId,
    String? toId,
  }) {
    return TextFieldLink(
      fromId: fromId?? this.fromId, 
      toId: toId?? this.toId,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TextFieldLink &&
    runtimeType == other.runtimeType &&
    fromId == other.fromId &&
    toId == other.toId;

  @override
  int get hashCode => super.hashCode ^ fromId.hashCode ^ toId.hashCode;

  Map<String, Object> toJson() {
    return {
      'f': fromId,
      't': toId,
    };
  }

  static TextFieldLink fromJson(Map<String, dynamic> json) {
    return TextFieldLink(
      fromId: json['f'] as String, 
      toId: json['t'] as String,
    );
  }
}