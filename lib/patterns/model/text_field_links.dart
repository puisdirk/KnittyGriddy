import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/patterns/model/text_field_link.dart';

@immutable
class TextFieldLinks {
  final List<TextFieldLink> links;

  const TextFieldLinks({
    this.links = const[],
  });

  TextFieldLinks copyWith({
    List<TextFieldLink>? links,
  }) {
    return TextFieldLinks(
      links: links?? this.links,
    );
  }

  bool hasLink(String id) => links.any((l) => l.fromId == id || l.toId == id);
  bool hasOutgoingLink(String id) => links.any((l) => l.fromId == id);
  bool hasIncomingLink(String id) => links.any((l) => l.toId == id);

  TextFieldLinks removeLinksForField(String fieldId) {
    return copyWith(links: links.where((l) => l.fromId != fieldId && l.toId != fieldId).toList());
  }

  TextFieldLinks addLink(String fromFieldId, String toFieldId) {
    // Avoid adding doubles + avoid linking in reverse
    if (links.any((l) => (l.fromId == fromFieldId && l.toId == toFieldId) || (l.toId == fromFieldId && l.fromId == toFieldId))) {
      return this;
    }
    return copyWith(links: List.from(links)..add(TextFieldLink(fromId: fromFieldId, toId: toFieldId)));
  }

  TextFieldLinks removeLink(TextFieldLink link) => copyWith(links: links.where((l) => l != link).toList());

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TextFieldLinks &&
    runtimeType == other.runtimeType &&
    listEquals(links, other.links);
  
  @override
  int get hashCode => super.hashCode ^ links.hashCode;

  Map<String, Object> toJson() {
    return {
      'links': links.map((e) => e.toJson()).toList()
    };
  }

  static TextFieldLinks fromJson(Map<String, dynamic> json) {
    List<TextFieldLink> linksList = [];
    List<Map<String, dynamic>> linkObjects = (json['links'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> linkObject in linkObjects) {
      linksList.add(TextFieldLink.fromJson(linkObject));
    }

    return TextFieldLinks(links: linksList);
  }
}