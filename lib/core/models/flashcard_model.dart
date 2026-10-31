class FlashcardModel {
  final String id;
  final String topicId;
  final String word;
  final String phonetic;
  final String meaning;
  final String example;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;

  FlashcardModel({
    required this.id,
    required this.topicId,
    required this.word,
    required this.phonetic,
    required this.meaning,
    this.example = '',
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'word': word,
      'phonetic': phonetic,
      'meaning': meaning,
      'example': example,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
    };
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] as String,
      topicId: map['topicId'] as String,
      word: map['word'] as String,
      phonetic: map['phonetic'] as String,
      meaning: map['meaning'] as String,
      example: map['example'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      audioUrl: map['audioUrl'] as String?,
      videoUrl: map['videoUrl'] as String?,
    );
  }
}

