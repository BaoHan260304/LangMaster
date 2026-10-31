class TopicModel {
  final String id;
  final String title;
  final String description;
  final int flashcardCount;
  final String iconName;
  final bool isCustom;

  TopicModel({
    required this.id,
    required this.title,
    required this.description,
    this.flashcardCount = 0,
    this.iconName = 'school',
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'flashcardCount': flashcardCount,
      'iconName': iconName,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      flashcardCount: (map['flashcardCount'] as int?) ?? 0,
      iconName: (map['iconName'] as String?) ?? 'school',
      isCustom: (map['isCustom'] == 1 || map['isCustom'] == true),
    );
  }
}

