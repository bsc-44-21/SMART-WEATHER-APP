class PlotModel {
  final String id;
  final String name;
  final String location;
  final String size;
  final String userId;
  final String date;
  final String status;

  PlotModel({
    required this.id,
    required this.name,
    required this.location,
    required this.size,
    required this.date,
    required this.userId,
    this.status = 'Active Growth',
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'size': size,
      'date': date,
      'status': status,
      'userId': userId,
    };
  }

  factory PlotModel.fromMap(Map<String, dynamic> map, String docId) {
    return PlotModel(
      id: docId,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      size: map['size'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'Active Growth',
      userId: map['userId'] ?? '',
    );
  }
}
