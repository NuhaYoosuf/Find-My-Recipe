import 'package:hive_flutter/hive_flutter.dart';
import 'package:find_my_reciepe/models/ingredient.dart';
import 'package:find_my_reciepe/models/recipe.dart';
import 'package:find_my_reciepe/models/shopping_item.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<Ingredient> _ingredientsBox;
  late Box<Recipe> _recipesBox;
  late Box<ShoppingItem> _shoppingItemsBox;
  late Box<dynamic> _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(IngredientAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecipeIngredientAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ShoppingItemAdapter());
    }

    // Open boxes
    _ingredientsBox = await Hive.openBox<Ingredient>(AppConstants.ingredientsBoxName);
    _recipesBox = await Hive.openBox<Recipe>(AppConstants.recipesBoxName);
    _shoppingItemsBox = await Hive.openBox<ShoppingItem>(AppConstants.shoppingItemsBoxName);
    _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  }

  // Ingredient operations
  Future<void> addIngredient(Ingredient ingredient) async {
    await _ingredientsBox.add(ingredient);
  }

  Future<void> updateIngredient(int index, Ingredient ingredient) async {
    await _ingredientsBox.putAt(index, ingredient);
  }

  Future<void> deleteIngredient(int index) async {
    await _ingredientsBox.deleteAt(index);
  }

  List<Ingredient> getAllIngredients() {
    return _ingredientsBox.values.toList();
  }

  List<Ingredient> getIngredientsByCategory(String category) {
    return _ingredientsBox.values
        .where((ingredient) => ingredient.category == category)
        .toList();
  }

  List<Ingredient> searchIngredients(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _ingredientsBox.values
        .where((ingredient) => ingredient.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  List<Ingredient> getExpiringSoonIngredients() {
    return _ingredientsBox.values
        .where((ingredient) => ingredient.isExpiringSoon)
        .toList();
  }

  List<Ingredient> getExpiredIngredients() {
    return _ingredientsBox.values
        .where((ingredient) => ingredient.isExpired)
        .toList();
  }

  Future<void> clearAllIngredients() async {
    await _ingredientsBox.clear();
  }

  // Recipe operations
  Future<void> saveRecipe(Recipe recipe) async {
    // Check if recipe already exists
    final existingIndex = _recipesBox.values
        .toList()
        .indexWhere((r) => r.id == recipe.id);
    
    if (existingIndex != -1) {
      await _recipesBox.putAt(existingIndex, recipe);
    } else {
      await _recipesBox.add(recipe);
    }
  }

  Future<void> deleteRecipe(int recipeId) async {
    final recipes = _recipesBox.values.toList();
    final index = recipes.indexWhere((recipe) => recipe.id == recipeId);
    if (index != -1) {
      await _recipesBox.deleteAt(index);
    }
  }

  List<Recipe> getAllSavedRecipes() {
    return _recipesBox.values.toList();
  }

  List<Recipe> getFavoriteRecipes() {
    return _recipesBox.values
        .where((recipe) => recipe.isFavorite)
        .toList();
  }

  Recipe? getRecipeById(int recipeId) {
    return _recipesBox.values
        .firstWhere((recipe) => recipe.id == recipeId);
  }

  Future<void> toggleRecipeFavorite(int recipeId) async {
    final recipes = _recipesBox.values.toList();
    final index = recipes.indexWhere((recipe) => recipe.id == recipeId);
    if (index != -1) {
      final recipe = recipes[index];
      recipe.isFavorite = !recipe.isFavorite;
      await _recipesBox.putAt(index, recipe);
    }
  }

  List<Recipe> searchRecipes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _recipesBox.values
        .where((recipe) => 
            recipe.title.toLowerCase().contains(lowercaseQuery) ||
            recipe.ingredients.any((ingredient) => 
                ingredient.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  Future<void> clearRecipeCache() async {
    // Keep only favorite recipes
    final favorites = getFavoriteRecipes();
    await _recipesBox.clear();
    for (var recipe in favorites) {
      await _recipesBox.add(recipe);
    }
  }

  // Shopping list operations
  Future<void> addShoppingItem(ShoppingItem item) async {
    await _shoppingItemsBox.add(item);
  }

  Future<void> updateShoppingItem(int index, ShoppingItem item) async {
    await _shoppingItemsBox.putAt(index, item);
  }

  Future<void> deleteShoppingItem(int index) async {
    await _shoppingItemsBox.deleteAt(index);
  }

  Future<void> toggleShoppingItemCompleted(int index) async {
    final item = _shoppingItemsBox.getAt(index);
    if (item != null) {
      item.isCompleted = !item.isCompleted;
      await _shoppingItemsBox.putAt(index, item);
    }
  }

  List<ShoppingItem> getAllShoppingItems() {
    return _shoppingItemsBox.values.toList();
  }

  List<ShoppingItem> getPendingShoppingItems() {
    return _shoppingItemsBox.values
        .where((item) => !item.isCompleted)
        .toList();
  }

  List<ShoppingItem> getCompletedShoppingItems() {
    return _shoppingItemsBox.values
        .where((item) => item.isCompleted)
        .toList();
  }

  List<ShoppingItem> getShoppingItemsByCategory(String category) {
    return _shoppingItemsBox.values
        .where((item) => item.category == category)
        .toList();
  }

  Future<void> clearCompletedShoppingItems() async {
    final itemsToKeep = getPendingShoppingItems();
    await _shoppingItemsBox.clear();
    for (var item in itemsToKeep) {
      await _shoppingItemsBox.add(item);
    }
  }

  Future<void> clearAllShoppingItems() async {
    await _shoppingItemsBox.clear();
  }

  // Settings operations
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // App-specific settings
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await setSetting('first_launch', isFirstLaunch);
  }

  bool isFirstLaunch() {
    return getSetting<bool>('first_launch', defaultValue: true) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await setSetting('notifications_enabled', enabled);
  }

  bool areNotificationsEnabled() {
    return getSetting<bool>('notifications_enabled', defaultValue: true) ?? true;
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    await setSetting('dark_mode_enabled', enabled);
  }

  bool isDarkModeEnabled() {
    return getSetting<bool>('dark_mode_enabled', defaultValue: false) ?? false;
  }

  Future<void> setPreferredCuisine(String cuisine) async {
    await setSetting('preferred_cuisine', cuisine);
  }

  String? getPreferredCuisine() {
    return getSetting<String>('preferred_cuisine');
  }

  Future<void> setDietaryRestrictions(List<String> restrictions) async {
    await setSetting('dietary_restrictions', restrictions);
  }

  List<String> getDietaryRestrictions() {
    final restrictions = getSetting<List>('dietary_restrictions', defaultValue: []);
    return restrictions?.cast<String>() ?? [];
  }

  Future<void> setLastRecipeSync(DateTime dateTime) async {
    await setSetting('last_recipe_sync', dateTime.toIso8601String());
  }

  DateTime? getLastRecipeSync() {
    final dateString = getSetting<String>('last_recipe_sync');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // Cleanup and maintenance
  Future<void> performMaintenance() async {
    // Remove expired cached recipes
    final lastSync = getLastRecipeSync();
    if (lastSync != null && 
        DateTime.now().difference(lastSync) > AppConstants.cacheExpiry) {
      await clearRecipeCache();
      await setLastRecipeSync(DateTime.now());
    }

    // Remove old completed shopping items (older than 7 days)
    final oldDate = DateTime.now().subtract(const Duration(days: 7));
    final items = _shoppingItemsBox.values.toList();
    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      if (item.isCompleted && item.addedDate.isBefore(oldDate)) {
        await _shoppingItemsBox.deleteAt(i);
      }
    }
  }

  Future<void> clearAllData() async {
    await _ingredientsBox.clear();
    await _recipesBox.clear();
    await _shoppingItemsBox.clear();
    await _settingsBox.clear();
  }

  Future<void> dispose() async {
    await _ingredientsBox.close();
    await _recipesBox.close();
    await _shoppingItemsBox.close();
    await _settingsBox.close();
  }

  // Statistics
  Map<String, int> getIngredientStats() {
    final ingredients = getAllIngredients();
    Map<String, int> stats = {};
    
    for (var ingredient in ingredients) {
      stats[ingredient.category] = (stats[ingredient.category] ?? 0) + 1;
    }
    
    return stats;
  }

  Map<String, dynamic> getAppStats() {
    return {
      'total_ingredients': _ingredientsBox.length,
      'total_recipes': _recipesBox.length,
      'favorite_recipes': getFavoriteRecipes().length,
      'shopping_items': _shoppingItemsBox.length,
      'expiring_soon': getExpiringSoonIngredients().length,
      'expired_items': getExpiredIngredients().length,
    };
  }
}