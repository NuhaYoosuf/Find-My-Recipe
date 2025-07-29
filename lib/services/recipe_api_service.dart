import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:find_my_reciepe/models/recipe.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class RecipeApiService {
  static final RecipeApiService _instance = RecipeApiService._internal();
  factory RecipeApiService() => _instance;
  RecipeApiService._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.spoonacularBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // Only log in debug mode
        print(object);
      },
    ));
  }

  Future<List<Recipe>> findRecipesByIngredients({
    required List<String> ingredients,
    int number = 12,
    bool ignorePantry = true,
    int ranking = 1,
  }) async {
    try {
      final ingredientsQuery = ingredients.join(',');
      
      final response = await _dio.get(
        '/findByIngredients',
        queryParameters: {
          'apiKey': AppConstants.spoonacularApiKey,
          'ingredients': ingredientsQuery,
          'number': number,
          'ignorePantry': ignorePantry,
          'ranking': ranking,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<Recipe> recipes = [];

        for (var item in data) {
          // Get detailed recipe information
          final detailedRecipe = await getRecipeInformation(item['id']);
          if (detailedRecipe != null) {
            recipes.add(detailedRecipe);
          }
        }

        return recipes;
      } else {
        throw Exception('Failed to fetch recipes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Recipe?> getRecipeInformation(int recipeId) async {
    try {
      final response = await _dio.get(
        '/$recipeId/information',
        queryParameters: {
          'apiKey': AppConstants.spoonacularApiKey,
          'includeNutrition': false,
        },
      );

      if (response.statusCode == 200) {
        return _parseRecipeFromSpoonacular(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching recipe information: $e');
      return null;
    }
  }

  Future<List<Recipe>> searchRecipes({
    String? query,
    List<String>? includeIngredients,
    List<String>? excludeIngredients,
    String? diet,
    String? cuisine,
    String? type,
    int? maxReadyTime,
    int number = 12,
    int offset = 0,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'apiKey': AppConstants.spoonacularApiKey,
        'number': number,
        'offset': offset,
        'addRecipeInformation': true,
        'fillIngredients': true,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (includeIngredients != null && includeIngredients.isNotEmpty) {
        queryParams['includeIngredients'] = includeIngredients.join(',');
      }
      if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
        queryParams['excludeIngredients'] = excludeIngredients.join(',');
      }
      if (diet != null && diet.isNotEmpty) {
        queryParams['diet'] = diet.toLowerCase();
      }
      if (cuisine != null && cuisine.isNotEmpty) {
        queryParams['cuisine'] = cuisine.toLowerCase();
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type.toLowerCase();
      }
      if (maxReadyTime != null) {
        queryParams['maxReadyTime'] = maxReadyTime;
      }

      final response = await _dio.get(
        '/complexSearch',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> results = data['results'] ?? [];
        
        return results.map((item) => _parseRecipeFromSpoonacular(item)).toList();
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<String>> getRecipeInstructions(int recipeId) async {
    try {
      final response = await _dio.get(
        '/$recipeId/analyzedInstructions',
        queryParameters: {
          'apiKey': AppConstants.spoonacularApiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<String> instructions = [];

        for (var instruction in data) {
          final steps = instruction['steps'] as List<dynamic>?;
          if (steps != null) {
            for (var step in steps) {
              instructions.add(step['step'] ?? '');
            }
          }
        }

        return instructions;
      }
      return [];
    } catch (e) {
      print('Error fetching recipe instructions: $e');
      return [];
    }
  }

  Recipe _parseRecipeFromSpoonacular(Map<String, dynamic> data) {
    // Parse ingredients
    List<String> ingredients = [];
    List<RecipeIngredient> extendedIngredients = [];

    if (data['extendedIngredients'] != null) {
      for (var ingredient in data['extendedIngredients']) {
        ingredients.add(ingredient['original'] ?? ingredient['name'] ?? '');
        extendedIngredients.add(RecipeIngredient(
          name: ingredient['name'] ?? '',
          amount: (ingredient['amount'] ?? 0).toDouble(),
          unit: ingredient['unit'] ?? '',
          image: ingredient['image'],
        ));
      }
    }

    // Parse instructions
    List<String> instructions = [];
    if (data['analyzedInstructions'] != null) {
      for (var instruction in data['analyzedInstructions']) {
        final steps = instruction['steps'] as List<dynamic>?;
        if (steps != null) {
          for (var step in steps) {
            instructions.add(step['step'] ?? '');
          }
        }
      }
    } else if (data['instructions'] != null) {
      // Fallback for simple instructions
      instructions.add(data['instructions']);
    }

    return Recipe(
      id: data['id'] ?? 0,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      ingredients: ingredients,
      instructions: instructions,
      readyInMinutes: data['readyInMinutes'] ?? 0,
      servings: data['servings'] ?? 1,
      vegetarian: data['vegetarian'] ?? false,
      vegan: data['vegan'] ?? false,
      glutenFree: data['glutenFree'] ?? false,
      dairyFree: data['dairyFree'] ?? false,
      summary: data['summary'],
      sourceUrl: data['sourceUrl'],
      cuisines: List<String>.from(data['cuisines'] ?? []),
      dishTypes: List<String>.from(data['dishTypes'] ?? []),
      spoonacularScore: data['spoonacularScore']?.toDouble(),
      healthScore: data['healthScore'],
      extendedIngredients: extendedIngredients,
    );
  }

  // Mock data for development/testing when API key is not available
  List<Recipe> getMockRecipes() {
    return [
      Recipe(
        id: 1,
        title: 'Spaghetti Carbonara',
        image: 'https://example.com/carbonara.jpg',
        ingredients: ['Spaghetti', 'Eggs', 'Bacon', 'Parmesan cheese', 'Black pepper'],
        instructions: [
          'Cook spaghetti according to package directions',
          'Fry bacon until crispy',
          'Beat eggs with parmesan cheese',
          'Mix hot pasta with egg mixture',
          'Add bacon and black pepper'
        ],
        readyInMinutes: 20,
        servings: 4,
        vegetarian: false,
        cuisines: ['Italian'],
        dishTypes: ['Main Course'],
      ),
      Recipe(
        id: 2,
        title: 'Vegetable Stir Fry',
        image: 'https://example.com/stirfry.jpg',
        ingredients: ['Mixed vegetables', 'Soy sauce', 'Garlic', 'Ginger', 'Oil'],
        instructions: [
          'Heat oil in a wok',
          'Add garlic and ginger',
          'Add vegetables and stir-fry',
          'Add soy sauce and toss',
          'Serve hot'
        ],
        readyInMinutes: 15,
        servings: 2,
        vegetarian: true,
        vegan: true,
        cuisines: ['Asian'],
        dishTypes: ['Main Course'],
      ),
    ];
  }
}