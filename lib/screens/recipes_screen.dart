import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_my_reciepe/providers/app_provider.dart';
import 'package:find_my_reciepe/widgets/recipe_card.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoadingRecipes) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            );
          }

          final recipes = appProvider.filteredRecipes;

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_outlined,
                    size: 80,
                    color: AppConstants.textSecondaryColor,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  const Text(
                    'No recipes found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  const Text(
                    'Add ingredients to get recipe suggestions',
                    style: TextStyle(color: AppConstants.textSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  ElevatedButton(
                    onPressed: () => appProvider.searchRecipesByIngredients(),
                    child: const Text('Search Recipes'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.defaultPadding,
              mainAxisSpacing: AppConstants.defaultPadding,
              childAspectRatio: 0.75,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  // TODO: Navigate to recipe details
                },
                onFavoritePressed: () {
                  appProvider.toggleRecipeFavorite(recipe);
                },
              );
            },
          );
        },
      ),
    );
  }
}