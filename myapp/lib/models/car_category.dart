// lib/models/car_category.dart

class CarCategory {
  final String id;
  final String name;
  final String image;
  final double pricePerKm;
  final String description;
  final List<String> features;
  final int seatingCapacity;
  final int estimatedTime;

  CarCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.pricePerKm,
    required this.description,
    required this.features,
    required this.seatingCapacity,
    required this.estimatedTime,
  });
}
