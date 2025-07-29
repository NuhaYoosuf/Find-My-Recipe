import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_my_reciepe/providers/app_provider.dart';
import 'package:find_my_reciepe/widgets/ingredient_card.dart';
import 'package:find_my_reciepe/screens/ingredient_scanner_screen.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const IngredientScannerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final ingredients = appProvider.filteredIngredients;

          return Column(
            children: [
              // Search and filter bar
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                color: AppConstants.cardColor,
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search ingredients...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  appProvider.setSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                      onChanged: (value) {
                        appProvider.setSearchQuery(value);
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Category filter chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.ingredientCategories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: const Text('All'),
                                selected: appProvider.selectedCategory.isEmpty,
                                onSelected: (selected) {
                                  appProvider.setSelectedCategory('');
                                },
                              ),
                            );
                          }
                          
                          final category = AppConstants.ingredientCategories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: appProvider.selectedCategory == category,
                              onSelected: (selected) {
                                appProvider.setSelectedCategory(selected ? category : '');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Stats row
              if (ingredients.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      _buildStatChip(
                        '${ingredients.length}',
                        'Total',
                        AppConstants.primaryColor,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      _buildStatChip(
                        '${appProvider.expiringSoonIngredients.length}',
                        'Expiring Soon',
                        AppConstants.warningColor,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      _buildStatChip(
                        '${appProvider.expiredIngredients.length}',
                        'Expired',
                        AppConstants.errorColor,
                      ),
                    ],
                  ),
                ),

              // Ingredients list/grid
              Expanded(
                child: ingredients.isEmpty
                    ? _buildEmptyState(context)
                    : _buildIngredientsList(ingredients, appProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const IngredientScannerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 80,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'Your pantry is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'Start by adding some ingredients to your pantry',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const IngredientScannerScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredients'),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(ingredients, AppProvider appProvider) {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.defaultPadding,
          mainAxisSpacing: AppConstants.defaultPadding,
          childAspectRatio: 0.8,
        ),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return IngredientCard(
            ingredient: ingredient,
            showDeleteButton: true,
            onTap: () {
              // Show ingredient details
            },
            onDelete: () {
              _showDeleteConfirmation(context, appProvider, index, ingredient.name);
            },
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return IngredientListTile(
            ingredient: ingredient,
            onTap: () {
              // Show ingredient details
            },
            onEdit: () {
              // Show edit dialog
            },
            onDelete: () {
              _showDeleteConfirmation(context, appProvider, index, ingredient.name);
            },
          );
        },
      );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AppProvider appProvider,
    int index,
    String ingredientName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Ingredient'),
          content: Text('Are you sure you want to delete "$ingredientName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                appProvider.deleteIngredient(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted $ingredientName'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppConstants.errorColor),
              ),
            ),
          ],
        );
      },
    );
  }
}