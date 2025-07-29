import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 1)
class Recipe extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String image;

  @HiveField(3)
  List<String> ingredients;

  @HiveField(4)
  List<String> instructions;

  @HiveField(5)
  int readyInMinutes;

  @HiveField(6)
  int servings;

  @HiveField(7)
  bool vegetarian;

  @HiveField(8)
  bool vegan;

  @HiveField(9)
  bool glutenFree;

  @HiveField(10)
  bool dairyFree;

  @HiveField(11)
  String? summary;

  @HiveField(12)
  String? sourceUrl;

  @HiveField(13)
  List<String> cuisines;

  @HiveField(14)
  List<String> dishTypes;

  @HiveField(15)
  double? spoonacularScore;

  @HiveField(16)
  int? healthScore;

  @HiveField(17)
  bool isFavorite;

  @HiveField(18)
  DateTime? savedDate;

  @HiveField(19)
  List<RecipeIngredient> extendedIngredients;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.ingredients,
    required this.instructions,
    required this.readyInMinutes,
    required this.servings,
    this.vegetarian = false,
    this.vegan = false,
    this.glutenFree = false,
    this.dairyFree = false,
    this.summary,
    this.sourceUrl,
    this.cuisines = const [],
    this.dishTypes = const [],
    this.spoonacularScore,
    this.healthScore,
    this.isFavorite = false,
    this.savedDate,
    this.extendedIngredients = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'ingredients': ingredients,
      'instructions': instructions,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'vegetarian': vegetarian,
      'vegan': vegan,
      'glutenFree': glutenFree,
      'dairyFree': dairyFree,
      'summary': summary,
      'sourceUrl': sourceUrl,
      'cuisines': cuisines,
      'dishTypes': dishTypes,
      'spoonacularScore': spoonacularScore,
      'healthScore': healthScore,
      'isFavorite': isFavorite,
      'savedDate': savedDate?.toIso8601String(),
      'extendedIngredients': extendedIngredients.map((e) => e.toJson()).toList(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 1,
      vegetarian: json['vegetarian'] ?? false,
      vegan: json['vegan'] ?? false,
      glutenFree: json['glutenFree'] ?? false,
      dairyFree: json['dairyFree'] ?? false,
      summary: json['summary'],
      sourceUrl: json['sourceUrl'],
      cuisines: List<String>.from(json['cuisines'] ?? []),
      dishTypes: List<String>.from(json['dishTypes'] ?? []),
      spoonacularScore: json['spoonacularScore']?.toDouble(),
      healthScore: json['healthScore'],
      isFavorite: json['isFavorite'] ?? false,
      savedDate: json['savedDate'] != null 
          ? DateTime.parse(json['savedDate']) 
          : null,
      extendedIngredients: (json['extendedIngredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e))
          .toList() ?? [],
    );
  }

  List<String> get missingIngredients {
    // This would be calculated based on user's pantry
    // For now, returning empty list
    return [];
  }

  String get difficultyLevel {
    if (readyInMinutes <= 15) return 'Easy';
    if (readyInMinutes <= 45) return 'Medium';
    return 'Hard';
  }

  String get cookTimeText {
    if (readyInMinutes < 60) {
      return '$readyInMinutes min';
    } else {
      final hours = readyInMinutes ~/ 60;
      final minutes = readyInMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}

@HiveType(typeId: 2)
class RecipeIngredient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String unit;

  @HiveField(3)
  String? image;

  RecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'image': image,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      image: json['image'],
    );
  }

  String get displayText {
    return '$amount $unit $name';
  }
}