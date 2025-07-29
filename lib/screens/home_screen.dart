import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_my_reciepe/providers/app_provider.dart';
import 'package:find_my_reciepe/screens/pantry_screen.dart';
import 'package:find_my_reciepe/screens/recipes_screen.dart';
import 'package:find_my_reciepe/screens/shopping_screen.dart';
import 'package:find_my_reciepe/screens/profile_screen.dart';
import 'package:find_my_reciepe/screens/ingredient_scanner_screen.dart';
import 'package:find_my_reciepe/widgets/recipe_card.dart';
import 'package:find_my_reciepe/widgets/ingredient_card.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const PantryScreen(),
    const RecipesScreen(),
    const ShoppingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: AppStrings.pantryTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: AppStrings.recipesTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: AppStrings.shoppingTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profileTab,
          ),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appProvider.errorMessage!),
                  backgroundColor: AppConstants.errorColor,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      appProvider.clearError();
                    },
                  ),
                ),
              );
            });
          }

          return RefreshIndicator(
            onRefresh: () async {
              await appProvider.searchRecipesByIngredients();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  _buildWelcomeSection(context, appProvider),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Quick actions
                  _buildQuickActions(context, appProvider),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Pantry overview
                  _buildPantryOverview(context, appProvider),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Recipe suggestions
                  _buildRecipeSuggestions(context, appProvider),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Expiring soon section
                  if (appProvider.expiringSoonIngredients.isNotEmpty)
                    _buildExpiringSoonSection(context, appProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AppProvider appProvider) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning!';
    } else if (hour < 17) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryLightColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to cook today?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${appProvider.ingredients.length}',
                  'Ingredients',
                  Icons.kitchen,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _buildStatCard(
                  '${appProvider.favoriteRecipes.length}',
                  'Favorites',
                  Icons.favorite,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _buildStatCard(
                  '${appProvider.pendingShoppingItems.length}',
                  'Shopping',
                  Icons.shopping_cart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider appProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Scan Ingredients',
                Icons.camera_alt,
                AppConstants.primaryColor,
                () => _navigateToScanner(context),
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: _buildActionCard(
                'Find Recipes',
                Icons.search,
                AppConstants.accentColor,
                () => _searchRecipes(context, appProvider),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPantryOverview(BuildContext context, AppProvider appProvider) {
    final ingredients = appProvider.ingredients.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Pantry',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to pantry screen
                // This would be handled by the parent widget
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (ingredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.kitchen_outlined,
                  size: 48,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                const Text(
                  'Your pantry is empty',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                const Text(
                  'Start by adding some ingredients',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ElevatedButton.icon(
                  onPressed: () => _navigateToScanner(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredients'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: AppConstants.smallPadding),
                  child: IngredientCard(
                    ingredient: ingredients[index],
                    onTap: () {
                      // Show ingredient details
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecipeSuggestions(BuildContext context, AppProvider appProvider) {
    final recipes = appProvider.recipes.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recipe Suggestions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to recipes screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (appProvider.isLoadingRecipes)
          const Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          )
        else if (recipes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: 48,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                const Text(
                  'No recipes found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                const Text(
                  'Add ingredients to get recipe suggestions',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ElevatedButton(
                  onPressed: () => _searchRecipes(context, appProvider),
                  child: const Text('Search Recipes'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: AppConstants.defaultPadding),
                  child: RecipeCard(
                    recipe: recipes[index],
                    onTap: () {
                      // Navigate to recipe details
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExpiringSoonSection(BuildContext context, AppProvider appProvider) {
    final expiringIngredients = appProvider.expiringSoonIngredients;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: AppConstants.warningColor,
              size: 24,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            const Text(
              'Expiring Soon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppConstants.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.warningColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              ...expiringIngredients.take(3).map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppConstants.warningColor,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Text(
                          ingredient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        ingredient.expiryDate != null
                            ? '${ingredient.expiryDate!.difference(DateTime.now()).inDays} days'
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.warningColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (expiringIngredients.length > 3)
                Text(
                  '+ ${expiringIngredients.length - 3} more items',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const IngredientScannerScreen(),
      ),
    );
  }

  void _searchRecipes(BuildContext context, AppProvider appProvider) {
    appProvider.searchRecipesByIngredients();
  }
}