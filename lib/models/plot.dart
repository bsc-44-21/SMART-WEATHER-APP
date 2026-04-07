class PlotModel {
  final String id;
  final String name;
  final String location;
  final String latitude;
  final String longitude;
  final String fieldSize;
  final String userId;
  final String plantingDate;
  final String cropId;
  final String cropName;
  final String createdAt;
  final String modifiedAt;
  final String status;

  String get cropEmoji {
    final lower = cropName.toLowerCase();
    if (lower.contains('maize')) return '🌽';
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('nut') || lower.contains('g/nut')) return '🥜';
    if (lower.contains('coffee')) return '☕';
    if (lower.contains('cotton')) return '🌿';
    if (lower.contains('tobacco')) return '🚬';
    if (lower.contains('soy')) return '🌿';
    return '🌱';
  }

  PlotModel({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.fieldSize,
    required this.plantingDate,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.createdAt,
    required this.modifiedAt,
    this.status = 'Active Growth',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'field_size': fieldSize,
      'user_id': userId,
      'planting_date': plantingDate,
      'crop_id': cropId,
      'crop_name': cropName,
      'created_at': createdAt,
      'modified_at': modifiedAt,
      'status': status,
    };
  }

  factory PlotModel.fromMap(Map<String, dynamic> map, String docId) {
    return PlotModel(
      id: docId,
      name: (map['name'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      latitude: (map['latitude'] ?? '').toString(),
      longitude: (map['longitude'] ?? '').toString(),
      fieldSize: (map['field_size'] ?? map['size'] ?? '').toString(),
      plantingDate: (map['planting_date'] ?? map['date'] ?? '').toString(),
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      cropId: (map['crop_id'] ?? '').toString(),
      cropName: (map['crop_name'] ?? '').toString(),
      createdAt: (map['created_at'] ?? '').toString(),
      modifiedAt: (map['modified_at'] ?? '').toString(),
      status: (map['status'] ?? 'Active Growth').toString(),
    );
  }
}
