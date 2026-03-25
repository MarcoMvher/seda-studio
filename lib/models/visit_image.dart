class VisitImage {
  final int id;
  final int visitId;
  final String image;
  final String? imageUrl;
  final String? caption;
  final DateTime createdAt;

  VisitImage({
    required this.id,
    required this.visitId,
    required this.image,
    this.imageUrl,
    this.caption,
    required this.createdAt,
  });

  factory VisitImage.fromJson(Map<String, dynamic> json) {
    return VisitImage(
      id: json['id'],
      visitId: json['visit'],
      image: json['image'],
      imageUrl: json['image_url'],
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visit': visitId,
      'image': image,
      'image_url': imageUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
