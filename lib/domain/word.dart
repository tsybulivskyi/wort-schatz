class Word {
  final String id;
  final String original;
  final String translation;
  final List<Tag> tags;
  final DateTime createdAt;

  const Word({
    required this.id,
    required this.original,
    required this.translation,
    required this.tags,
    required this.createdAt,
  });
}

class Tag {
  final String id;
  final String name;

  Tag({required this.id, required this.name});
}
