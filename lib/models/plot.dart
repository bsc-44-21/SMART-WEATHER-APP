class PlotModel {
  final String id;
  final String name;
  final String location;
  final String fieldSize;
  final String userId;
  final String plantingDate;
  final String cropId;
  final String cropName;
  final String createdAt;
  final String modifiedAt;
  final String status;

  PlotModel({
    required this.id,
    required this.name,
    required this.location,
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
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      fieldSize: map['field_size'] ?? map['size'] ?? '',
      plantingDate: map['planting_date'] ?? map['date'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      cropId: map['crop_id'] ?? '',
      cropName: map['crop_name'] ?? '',
      createdAt: map['created_at'] ?? '',
      modifiedAt: map['modified_at'] ?? '',
      status: map['status'] ?? 'Active Growth',
    );
  }
}
