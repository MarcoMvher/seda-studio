class Measurement {
  final int id;
  final int visitId;
  final String spaceName;
  final double widthCm;
  final double heightCm;

  // Window and detail type
  final String? windowType;     // نوع الشباك - Window type (jarar, mufsala)
  final String? detailType;     // نوع التفصيل - Detail type (normal, crushing, wave, rings, roll_up)

  // Curtain/fabric specific fields
  final bool hasCurtain;      // بيت ستارة - Has curtain/rail
  final double? omq;          // عمق - Depth (cm) - only shown if hasCurtain is true
  final double? suqut;        // سقوط - Drop/Fall (cm) - only shown if hasCurtain is true
  final String? track;        // تراك - Track type
  final bool hasWood;         // خشب - Wood
  final double? windowToCeiling; // المساحة من الشباك للسقف - Area from window to ceiling (cm)

  // Measurement image
  final String? image;         // Image path
  final String? imageUrl;      // Full image URL

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Measurement({
    required this.id,
    required this.visitId,
    required this.spaceName,
    required this.widthCm,
    required this.heightCm,
    this.windowType,
    this.detailType,
    this.hasCurtain = false,
    this.omq,
    this.suqut,
    this.track,
    this.hasWood = false,
    this.windowToCeiling,
    this.image,
    this.imageUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      visitId: json['visit'],
      spaceName: json['space_name'],
      widthCm: double.parse(json['width_cm'].toString()),
      heightCm: double.parse(json['height_cm'].toString()),
      windowType: json['window_type'],
      detailType: json['detail_type'],
      hasCurtain: json['has_curtain'] ?? false,
      omq: json['omq'] != null ? double.tryParse(json['omq'].toString()) : null,
      suqut: json['suqut'] != null ? double.tryParse(json['suqut'].toString()) : null,
      track: json['track'],
      hasWood: json['has_wood'] ?? false,
      windowToCeiling: json['window_to_ceiling'] != null
          ? double.tryParse(json['window_to_ceiling'].toString())
          : null,
      image: json['image'],
      imageUrl: json['image_url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visit': visitId,
      'space_name': spaceName,
      'width_cm': widthCm,
      'height_cm': heightCm,
      if (windowType != null) 'window_type': windowType,
      if (detailType != null) 'detail_type': detailType,
      'has_curtain': hasCurtain,
      if (omq != null) 'omq': omq,
      if (suqut != null) 'suqut': suqut,
      if (track != null) 'track': track,
      'has_wood': hasWood,
      if (windowToCeiling != null) 'window_to_ceiling': windowToCeiling,
      if (image != null) 'image': image,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
