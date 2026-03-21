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