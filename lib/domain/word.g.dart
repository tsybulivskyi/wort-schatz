// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  (json['ID'] as num).toInt(),
  json['original'] as String,
  json['translation'] as String,
  (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  DateTime.parse(json['CreatedAt'] as String),
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'ID': instance.ID,
  'original': instance.original,
  'translation': instance.translation,
  'tags': instance.tags,
  'CreatedAt': instance.CreatedAt.toIso8601String(),
};
