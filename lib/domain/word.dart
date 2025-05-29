import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

@JsonSerializable()
class Word {
  int ID;
  String original;
  String translation;
  List<String> tags;
  DateTime CreatedAt;

  Word(this.ID, this.original, this.translation, this.tags, this.CreatedAt);

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);
}
