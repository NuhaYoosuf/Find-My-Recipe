import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';
import 'package:find_my_reciepe/models/ingredient.dart';

class ImageRecognitionService {
  static final ImageRecognitionService _instance = ImageRecognitionService._internal();
  factory ImageRecognitionService() => _instance;
  ImageRecognitionService._internal();

  late final ImageLabeler _imageLabeler;
  final ImagePicker _imagePicker = ImagePicker();

  void initialize() {
    final options = ImageLabelerOptions(
      confidenceThreshold: AppConstants.imageRecognitionConfidence,
    );
    _imageLabeler = ImageLabeler(options: options);
  }

  Future<void> dispose() async {
    await _imageLabeler.close();
  }

  Future<List<Ingredient>> recognizeIngredientsFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageSize.toDouble(),
        maxHeight: AppConstants.maxImageSize.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        return await _processImage(File(image.path));
      }
      return [];
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  Future<List<Ingredient>> recognizeIngredientsFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageSize.toDouble(),
        maxHeight: AppConstants.maxImageSize.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        return await _processImage(File(image.path));
      }
      return [];
    } catch (e) {
      throw Exception('Failed to select image: $e');
    }
  }

  Future<List<Ingredient>> recognizeIngredientsFromFile(File imageFile) async {
    try {
      return await _processImage(imageFile);
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  Future<List<Ingredient>> _processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

      List<Ingredient> recognizedIngredients = [];

      for (ImageLabel label in labels) {
        final ingredient = _mapLabelToIngredient(label);
        if (ingredient != null) {
          recognizedIngredients.add(ingredient);
        }
      }

      // Sort by confidence
      recognizedIngredients.sort((a, b) => b.name.compareTo(a.name));

      return recognizedIngredients;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  Ingredient? _mapLabelToIngredient(ImageLabel label) {
    final labelText = label.label.toLowerCase();
    final confidence = label.confidence;

    // Skip labels with low confidence
    if (confidence < AppConstants.imageRecognitionConfidence) {
      return null;
    }

    // Map common labels to ingredients
    final ingredientMapping = _getIngredientMapping();
    
    for (var mapping in ingredientMapping.entries) {
      if (mapping.value.any((keyword) => labelText.contains(keyword.toLowerCase()))) {
        return Ingredient(
          name: mapping.key,
          category: _getCategoryForIngredient(mapping.key),
          imageUrl: null, // Could store the processed image path here
        );
      }
    }

    // If no specific mapping found, check if it's a general food item
    if (_isFoodRelated(labelText)) {
      return Ingredient(
        name: _formatIngredientName(label.label),
        category: 'Other',
        imageUrl: null,
      );
    }

    return null;
  }

  Map<String, List<String>> _getIngredientMapping() {
    return {
      // Vegetables
      'Tomato': ['tomato', 'tomatoes'],
      'Onion': ['onion', 'onions'],
      'Carrot': ['carrot', 'carrots'],
      'Potato': ['potato', 'potatoes'],
      'Bell Pepper': ['pepper', 'bell pepper', 'capsicum'],
      'Broccoli': ['broccoli'],
      'Spinach': ['spinach', 'leafy green'],
      'Lettuce': ['lettuce', 'salad'],
      'Cucumber': ['cucumber'],
      'Garlic': ['garlic'],
      'Ginger': ['ginger'],
      'Mushroom': ['mushroom', 'mushrooms'],
      'Corn': ['corn', 'maize'],
      'Cabbage': ['cabbage'],
      'Cauliflower': ['cauliflower'],
      
      // Fruits
      'Apple': ['apple', 'apples'],
      'Banana': ['banana', 'bananas'],
      'Orange': ['orange', 'oranges'],
      'Lemon': ['lemon', 'lemons'],
      'Lime': ['lime', 'limes'],
      'Strawberry': ['strawberry', 'strawberries'],
      'Grapes': ['grape', 'grapes'],
      'Avocado': ['avocado'],
      'Mango': ['mango'],
      'Pineapple': ['pineapple'],
      
      // Proteins
      'Chicken': ['chicken', 'poultry'],
      'Beef': ['beef', 'meat'],
      'Pork': ['pork', 'ham'],
      'Fish': ['fish', 'salmon', 'tuna'],
      'Eggs': ['egg', 'eggs'],
      'Tofu': ['tofu'],
      
      // Dairy
      'Milk': ['milk'],
      'Cheese': ['cheese'],
      'Butter': ['butter'],
      'Yogurt': ['yogurt', 'yoghurt'],
      
      // Grains & Carbs
      'Rice': ['rice'],
      'Bread': ['bread', 'loaf'],
      'Pasta': ['pasta', 'noodles'],
      'Flour': ['flour'],
      'Oats': ['oats', 'oatmeal'],
      
      // Herbs & Spices
      'Basil': ['basil'],
      'Parsley': ['parsley'],
      'Cilantro': ['cilantro', 'coriander'],
      'Rosemary': ['rosemary'],
      'Thyme': ['thyme'],
      'Oregano': ['oregano'],
      
      // Others
      'Oil': ['oil', 'olive oil'],
      'Salt': ['salt'],
      'Sugar': ['sugar'],
      'Honey': ['honey'],
    };
  }

  String _getCategoryForIngredient(String ingredientName) {
    final vegetableIngredients = [
      'Tomato', 'Onion', 'Carrot', 'Potato', 'Bell Pepper', 'Broccoli',
      'Spinach', 'Lettuce', 'Cucumber', 'Garlic', 'Ginger', 'Mushroom',
      'Corn', 'Cabbage', 'Cauliflower'
    ];
    
    final fruitIngredients = [
      'Apple', 'Banana', 'Orange', 'Lemon', 'Lime', 'Strawberry',
      'Grapes', 'Avocado', 'Mango', 'Pineapple'
    ];
    
    final proteinIngredients = [
      'Chicken', 'Beef', 'Pork', 'Fish', 'Eggs', 'Tofu'
    ];
    
    final dairyIngredients = [
      'Milk', 'Cheese', 'Butter', 'Yogurt'
    ];
    
    final grainIngredients = [
      'Rice', 'Bread', 'Pasta', 'Flour', 'Oats'
    ];
    
    final herbIngredients = [
      'Basil', 'Parsley', 'Cilantro', 'Rosemary', 'Thyme', 'Oregano'
    ];

    if (vegetableIngredients.contains(ingredientName)) {
      return 'Vegetables';
    } else if (fruitIngredients.contains(ingredientName)) {
      return 'Fruits';
    } else if (proteinIngredients.contains(ingredientName)) {
      return 'Meat & Poultry';
    } else if (dairyIngredients.contains(ingredientName)) {
      return 'Dairy & Eggs';
    } else if (grainIngredients.contains(ingredientName)) {
      return 'Grains & Cereals';
    } else if (herbIngredients.contains(ingredientName)) {
      return 'Herbs & Spices';
    } else {
      return 'Other';
    }
  }

  bool _isFoodRelated(String label) {
    final foodKeywords = [
      'food', 'ingredient', 'vegetable', 'fruit', 'meat', 'dairy',
      'grain', 'herb', 'spice', 'produce', 'fresh', 'organic',
      'cooking', 'kitchen', 'recipe', 'meal', 'dish', 'cuisine'
    ];

    return foodKeywords.any((keyword) => label.contains(keyword));
  }

  String _formatIngredientName(String name) {
    // Capitalize first letter and make it singular if possible
    String formatted = name.toLowerCase();
    
    // Simple pluralization removal
    if (formatted.endsWith('s') && formatted.length > 3) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    
    // Capitalize first letter
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }
    
    return formatted;
  }

  // Helper method to get mock ingredients for testing
  List<Ingredient> getMockIngredients() {
    return [
      Ingredient(name: 'Tomato', category: 'Vegetables'),
      Ingredient(name: 'Onion', category: 'Vegetables'),
      Ingredient(name: 'Chicken', category: 'Meat & Poultry'),
      Ingredient(name: 'Rice', category: 'Grains & Cereals'),
      Ingredient(name: 'Cheese', category: 'Dairy & Eggs'),
    ];
  }
}