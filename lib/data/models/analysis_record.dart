class AnalysisRecord {
  final String id;
  final String text;
  final String analysis;
  final String? imagePath;
  final String? city;
  final double? price;
  final int? score;
  final DateTime createdAt;

  AnalysisRecord({
    required this.id,
    required this.text,
    required this.analysis,
    this.imagePath,
    this.city,
    this.price,
    this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'analysis': analysis,
    'image_path': imagePath,
    'city': city,
    'price': price,
    'score': score,
    'created_at': createdAt.toIso8601String(),
  };

  factory AnalysisRecord.fromMap(Map<String, dynamic> map) {
    return AnalysisRecord(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      analysis: map['analysis'] ?? '',
      imagePath: map['image_path'],
      city: map['city'],
      price: map['price']?.toDouble(),
      score: map['score'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
