import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 3)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String quantity;

  @HiveField(2)
  String category;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime addedDate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  int? recipeId;

  @HiveField(7)
  String? recipeName;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.category,
    this.isCompleted = false,
    DateTime? addedDate,
    this.notes,
    this.recipeId,
    this.recipeName,
  }) : addedDate = addedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'isCompleted': isCompleted,
      'addedDate': addedDate.toIso8601String(),
      'notes': notes,
      'recipeId': recipeId,
      'recipeName': recipeName,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
      addedDate: json['addedDate'] != null 
          ? DateTime.parse(json['addedDate']) 
          : DateTime.now(),
      notes: json['notes'],
      recipeId: json['recipeId'],
      recipeName: json['recipeName'],
    );
  }

  String get displayText {
    return '$quantity $name';
  }
}