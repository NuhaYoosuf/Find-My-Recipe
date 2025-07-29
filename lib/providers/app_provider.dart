import 'package:flutter/foundation.dart';
import 'package:find_my_reciepe/models/ingredient.dart';
import 'package:find_my_reciepe/models/recipe.dart';
import 'package:find_my_reciepe/models/shopping_item.dart';
import 'package:find_my_reciepe/services/storage_service.dart';
import 'package:find_my_reciepe/services/recipe_api_service.dart';
import 'package:find_my_reciepe/services/image_recognition_service.dart';
import 'package:find_my_reciepe/services/barcode_scanner_service.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final RecipeApiService _recipeApiService = RecipeApiService();
  final ImageRecognitionService _imageRecognitionService = ImageRecognitionService();
  final BarcodeScannerService _barcodeScannerService = BarcodeScannerService();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingRecipes = false;
  bool _isInitialized = false;

  // Data
  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  List<Recipe> _favoriteRecipes = [];
  List<ShoppingItem> _shoppingItems = [];

  // Filters and search
  String _searchQuery = '';
  String _selectedCategory = '';
  List<String> _selectedDietFilters = [];
  String _selectedCuisine = '';
  int _maxCookTime = 0;

  // Error handling
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingRecipes => _isLoadingRecipes;
  bool get isInitialized => _isInitialized;
  
  List<Ingredient> get ingredients => _ingredients;
  List<Recipe> get recipes => _recipes;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get selectedDietFilters => _selectedDietFilters;
  String get selectedCuisine => _selectedCuisine;
  int get maxCookTime => _maxCookTime;
  
  String? get errorMessage => _errorMessage;

  // Computed properties
  List<Ingredient> get expiringSoonIngredients =>
      _ingredients.where((ingredient) => ingredient.isExpiringSoon).toList();

  List<Ingredient> get expiredIngredients =>
      _ingredients.where((ingredient) => ingredient.isExpired).toList();

  List<ShoppingItem> get pendingShoppingItems =>
      _shoppingItems.where((item) => !item.isCompleted).toList();

  List<ShoppingItem> get completedShoppingItems =>
      _shoppingItems.where((item) => item.isCompleted).toList();

  Map<String, int> get ingredientStats {
    Map<String, int> stats = {};
    for (var ingredient in _ingredients) {
      stats[ingredient.category] = (stats[ingredient.category] ?? 0) + 1;
    }
    return stats;
  }

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await _storageService.initialize();
      _recipeApiService.initialize();
      _imageRecognitionService.initialize();

      await _loadLocalData();
      await _storageService.performMaintenance();

      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadLocalData() async {
    _ingredients = _storageService.getAllIngredients();
    _favoriteRecipes = _storageService.getFavoriteRecipes();
    _shoppingItems = _storageService.getAllShoppingItems();
    notifyListeners();
  }

  // Ingredient management
  Future<void> addIngredient(Ingredient ingredient) async {
    try {
      await _storageService.addIngredient(ingredient);
      _ingredients.add(ingredient);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add ingredient: $e');
    }
  }

  Future<void> updateIngredient(int index, Ingredient ingredient) async {
    try {
      await _storageService.updateIngredient(index, ingredient);
      _ingredients[index] = ingredient;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update ingredient: $e');
    }
  }

  Future<void> deleteIngredient(int index) async {
    try {
      await _storageService.deleteIngredient(index);
      _ingredients.removeAt(index);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete ingredient: $e');
    }
  }

  Future<void> addIngredientsFromImage() async {
    try {
      _setLoading(true);
      final recognizedIngredients = await _imageRecognitionService.recognizeIngredientsFromCamera();
      
      for (var ingredient in recognizedIngredients) {
        await addIngredient(ingredient);
      }
    } catch (e) {
      _setError('Failed to recognize ingredients: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addIngredientFromBarcode() async {
    try {
      _setLoading(true);
      // This would typically open a barcode scanner screen
      // For now, we'll use mock data
      final ingredient = Ingredient(
        name: 'Scanned Product',
        category: 'Other',
        isFromBarcode: true,
        barcode: '1234567890123',
      );
      await addIngredient(ingredient);
    } catch (e) {
      _setError('Failed to scan barcode: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Recipe management
  Future<void> searchRecipesByIngredients() async {
    if (_ingredients.isEmpty) {
      _setError('Please add some ingredients first');
      return;
    }

    _setLoadingRecipes(true);
    try {
      final ingredientNames = _ingredients
          .take(AppConstants.maxIngredientsForRecipeSearch)
          .map((ingredient) => ingredient.name)
          .toList();

      List<Recipe> foundRecipes;
      
      // Try to use real API first, fall back to mock data
      try {
        foundRecipes = await _recipeApiService.findRecipesByIngredients(
          ingredients: ingredientNames,
          number: AppConstants.recipesPerPage,
        );
      } catch (e) {
        print('API call failed, using mock data: $e');
        foundRecipes = _recipeApiService.getMockRecipes();
      }

      _recipes = foundRecipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to search recipes: $e');
    } finally {
      _setLoadingRecipes(false);
    }
  }

  Future<void> searchRecipes({
    String? query,
    String? cuisine,
    String? diet,
    int? maxReadyTime,
  }) async {
    _setLoadingRecipes(true);
    try {
      List<Recipe> foundRecipes;
      
      try {
        foundRecipes = await _recipeApiService.searchRecipes(
          query: query,
          cuisine: cuisine,
          diet: diet,
          maxReadyTime: maxReadyTime,
          number: AppConstants.recipesPerPage,
        );
      } catch (e) {
        print('API call failed, using mock data: $e');
        foundRecipes = _recipeApiService.getMockRecipes();
      }

      _recipes = foundRecipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to search recipes: $e');
    } finally {
      _setLoadingRecipes(false);
    }
  }

  Future<void> toggleRecipeFavorite(Recipe recipe) async {
    try {
      recipe.isFavorite = !recipe.isFavorite;
      if (recipe.isFavorite) {
        recipe.savedDate = DateTime.now();
      }
      
      await _storageService.saveRecipe(recipe);
      
      // Update local lists
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _recipes[index] = recipe;
      }
      
      if (recipe.isFavorite) {
        if (!_favoriteRecipes.any((r) => r.id == recipe.id)) {
          _favoriteRecipes.add(recipe);
        }
      } else {
        _favoriteRecipes.removeWhere((r) => r.id == recipe.id);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to update recipe favorite: $e');
    }
  }

  // Shopping list management
  Future<void> addShoppingItem(ShoppingItem item) async {
    try {
      await _storageService.addShoppingItem(item);
      _shoppingItems.add(item);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add shopping item: $e');
    }
  }

  Future<void> toggleShoppingItemCompleted(int index) async {
    try {
      await _storageService.toggleShoppingItemCompleted(index);
      _shoppingItems[index].isCompleted = !_shoppingItems[index].isCompleted;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update shopping item: $e');
    }
  }

  Future<void> deleteShoppingItem(int index) async {
    try {
      await _storageService.deleteShoppingItem(index);
      _shoppingItems.removeAt(index);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete shopping item: $e');
    }
  }

  Future<void> addMissingIngredientsToShoppingList(Recipe recipe) async {
    try {
      final userIngredientNames = _ingredients.map((i) => i.name.toLowerCase()).toSet();
      
      for (var recipeIngredient in recipe.extendedIngredients) {
        if (!userIngredientNames.contains(recipeIngredient.name.toLowerCase())) {
          final shoppingItem = ShoppingItem(
            name: recipeIngredient.name,
            quantity: recipeIngredient.displayText,
            category: _getCategoryForIngredient(recipeIngredient.name),
            recipeId: recipe.id,
            recipeName: recipe.title,
          );
          await addShoppingItem(shoppingItem);
        }
      }
    } catch (e) {
      _setError('Failed to add ingredients to shopping list: $e');
    }
  }

  String _getCategoryForIngredient(String ingredientName) {
    // Simple categorization logic - in a real app, this could be more sophisticated
    final name = ingredientName.toLowerCase();
    
    if (name.contains('chicken') || name.contains('beef') || name.contains('pork')) {
      return 'Meat & Poultry';
    } else if (name.contains('milk') || name.contains('cheese') || name.contains('yogurt')) {
      return 'Dairy & Eggs';
    } else if (name.contains('tomato') || name.contains('onion') || name.contains('pepper')) {
      return 'Vegetables';
    } else if (name.contains('apple') || name.contains('banana') || name.contains('orange')) {
      return 'Fruits';
    } else if (name.contains('rice') || name.contains('pasta') || name.contains('bread')) {
      return 'Grains & Cereals';
    } else {
      return 'Other';
    }
  }

  // Search and filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleDietFilter(String diet) {
    if (_selectedDietFilters.contains(diet)) {
      _selectedDietFilters.remove(diet);
    } else {
      _selectedDietFilters.add(diet);
    }
    notifyListeners();
  }

  void setSelectedCuisine(String cuisine) {
    _selectedCuisine = cuisine;
    notifyListeners();
  }

  void setMaxCookTime(int minutes) {
    _maxCookTime = minutes;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedDietFilters.clear();
    _selectedCuisine = '';
    _maxCookTime = 0;
    notifyListeners();
  }

  // Filtered data
  List<Ingredient> get filteredIngredients {
    var filtered = _ingredients;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((ingredient) =>
              ingredient.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((ingredient) => ingredient.category == _selectedCategory)
          .toList();
    }

    return filtered;
  }

  List<Recipe> get filteredRecipes {
    var filtered = _recipes;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((recipe) =>
              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              recipe.ingredients.any((ingredient) =>
                  ingredient.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    if (_selectedDietFilters.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return _selectedDietFilters.any((diet) {
          switch (diet.toLowerCase()) {
            case 'vegetarian':
              return recipe.vegetarian;
            case 'vegan':
              return recipe.vegan;
            case 'gluten free':
              return recipe.glutenFree;
            case 'dairy free':
              return recipe.dairyFree;
            default:
              return false;
          }
        });
      }).toList();
    }

    if (_selectedCuisine.isNotEmpty) {
      filtered = filtered
          .where((recipe) => recipe.cuisines.contains(_selectedCuisine))
          .toList();
    }

    if (_maxCookTime > 0) {
      filtered = filtered
          .where((recipe) => recipe.readyInMinutes <= _maxCookTime)
          .toList();
    }

    return filtered;
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingRecipes(bool loading) {
    _isLoadingRecipes = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
    
    // Clear error after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _errorMessage = null;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    _imageRecognitionService.dispose();
    _barcodeScannerService.dispose();
    super.dispose();
  }
}