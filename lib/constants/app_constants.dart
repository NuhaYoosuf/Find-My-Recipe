import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String spoonacularApiKey = 'YOUR_SPOONACULAR_API_KEY'; // Replace with actual key
  static const String spoonacularBaseUrl = 'https://api.spoonacular.com/recipes';
  
  // App Colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color primaryLightColor = Color(0xFF81C784);
  static const Color primaryDarkColor = Color(0xFF388E3C);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  
  // Ingredient Categories
  static const List<String> ingredientCategories = [
    'Vegetables',
    'Fruits',
    'Meat & Poultry',
    'Seafood',
    'Dairy & Eggs',
    'Grains & Cereals',
    'Legumes & Nuts',
    'Herbs & Spices',
    'Oils & Condiments',
    'Beverages',
    'Frozen Foods',
    'Canned Foods',
    'Bakery',
    'Snacks',
    'Other',
  ];
  
  // Recipe Filters
  static const List<String> cuisineTypes = [
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Thai',
    'Japanese',
    'French',
    'Mediterranean',
    'American',
    'Korean',
    'Greek',
    'Spanish',
    'Middle Eastern',
    'Other',
  ];
  
  static const List<String> dietTypes = [
    'Vegetarian',
    'Vegan',
    'Gluten Free',
    'Dairy Free',
    'Keto',
    'Paleo',
    'Low Carb',
    'High Protein',
  ];
  
  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
    'Appetizer',
    'Soup',
    'Salad',
    'Main Course',
    'Side Dish',
  ];
  
  // App Settings
  static const int maxIngredientsForRecipeSearch = 10;
  static const int recipesPerPage = 12;
  static const int maxRecipesCache = 100;
  static const Duration cacheExpiry = Duration(hours: 24);
  
  // Hive Box Names
  static const String ingredientsBoxName = 'ingredients';
  static const String recipesBoxName = 'recipes';
  static const String shoppingItemsBoxName = 'shopping_items';
  static const String settingsBoxName = 'settings';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Image Recognition Settings
  static const double imageRecognitionConfidence = 0.7;
  static const int maxImageSize = 1024;
  
  // Notification Settings
  static const String notificationChannelId = 'recipe_app_notifications';
  static const String notificationChannelName = 'Recipe App Notifications';
  static const String notificationChannelDescription = 'Notifications for recipe suggestions and ingredient reminders';
}

class AppStrings {
  // App Info
  static const String appName = 'Find My Recipe';
  static const String appDescription = 'Find recipes using ingredients you have';
  
  // Onboarding
  static const String onboardingTitle1 = 'Scan Your Ingredients';
  static const String onboardingDescription1 = 'Use your camera to identify ingredients or scan barcodes';
  static const String onboardingTitle2 = 'Get Recipe Suggestions';
  static const String onboardingDescription2 = 'Find delicious recipes based on what you have';
  static const String onboardingTitle3 = 'Reduce Food Waste';
  static const String onboardingDescription3 = 'Make the most of your ingredients and save money';
  
  // Navigation
  static const String homeTab = 'Home';
  static const String pantryTab = 'Pantry';
  static const String recipesTab = 'Recipes';
  static const String shoppingTab = 'Shopping';
  static const String profileTab = 'Profile';
  
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String clear = 'Clear';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String skip = 'Skip';
  static const String getStarted = 'Get Started';
  
  // Errors
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noRecipesFound = 'No recipes found for your ingredients.';
  static const String noIngredientsFound = 'No ingredients found.';
  static const String cameraPermissionDenied = 'Camera permission is required to scan ingredients.';
  static const String storagePermissionDenied = 'Storage permission is required to save images.';
}