class FaceEmbedding {
  final String id;
  final String userId;
  final List<double> embedding; // Face embedding vector
  final String imagePath; // Path to stored face image
  final DateTime createdAt;
  final bool isActive;

  FaceEmbedding({
    required this.id,
    required this.userId,
    required this.embedding,
    required this.imagePath,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert embedding list to comma-separated string for database
  String get embeddingString => embedding.join(',');

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'embedding': embeddingString,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create from Map
  factory FaceEmbedding.fromMap(Map<String, dynamic> map) {
    final embeddingString = map['embedding'] as String;
    final embedding = embeddingString
        .split(',')
        .map((e) => double.parse(e.trim()))
        .toList();

    return FaceEmbedding(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      embedding: embedding,
      imagePath: map['image_path'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  // Calculate cosine similarity with another embedding
  double cosineSimilarity(FaceEmbedding other) {
    if (embedding.length != other.embedding.length) {
      return 0.0;
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < embedding.length; i++) {
      dotProduct += embedding[i] * other.embedding[i];
      normA += embedding[i] * embedding[i];
      normB += other.embedding[i] * other.embedding[i];
    }

    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  double sqrt(double value) {
    // Simple square root implementation
    if (value == 0) return 0;
    double guess = value / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }
}

