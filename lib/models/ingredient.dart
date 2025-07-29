import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 0)
class Ingredient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String category;

  @HiveField(2)
  DateTime? expiryDate;

  @HiveField(3)
  String quantity;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  DateTime addedDate;

  @HiveField(6)
  bool isFromBarcode;

  @HiveField(7)
  String? barcode;

  Ingredient({
    required this.name,
    required this.category,
    this.expiryDate,
    this.quantity = '1',
    this.imageUrl,
    DateTime? addedDate,
    this.isFromBarcode = false,
    this.barcode,
  }) : addedDate = addedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
      'quantity': quantity,
      'imageUrl': imageUrl,
      'addedDate': addedDate.toIso8601String(),
      'isFromBarcode': isFromBarcode,
      'barcode': barcode,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      category: json['category'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      quantity: json['quantity'] ?? '1',
      imageUrl: json['imageUrl'],
      addedDate: json['addedDate'] != null 
          ? DateTime.parse(json['addedDate']) 
          : DateTime.now(),
      isFromBarcode: json['isFromBarcode'] ?? false,
      barcode: json['barcode'],
    );
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}