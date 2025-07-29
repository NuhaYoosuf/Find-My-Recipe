import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_my_reciepe/models/recipe.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final bool showFavoriteButton;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavoritePressed,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            _buildRecipeImage(),
            
            // Recipe details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and favorite button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showFavoriteButton)
                          IconButton(
                            icon: Icon(
                              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: recipe.isFavorite ? Colors.red : AppConstants.textSecondaryColor,
                              size: 20,
                            ),
                            onPressed: onFavoritePressed,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    // Recipe info row
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.access_time,
                          recipe.cookTimeText,
                          AppConstants.primaryColor,
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        _buildInfoChip(
                          Icons.restaurant,
                          '${recipe.servings} servings',
                          AppConstants.accentColor,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    // Difficulty and diet info
                    Row(
                      children: [
                        _buildDifficultyChip(recipe.difficultyLevel),
                        const Spacer(),
                        if (recipe.vegetarian)
                          _buildDietChip('Vegetarian', Colors.green),
                        if (recipe.vegan)
                          _buildDietChip('Vegan', Colors.lightGreen),
                        if (recipe.glutenFree)
                          _buildDietChip('GF', Colors.orange),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    // Ingredients preview
                    if (recipe.ingredients.isNotEmpty)
                      Text(
                        'Ingredients: ${recipe.ingredients.take(3).join(', ')}${recipe.ingredients.length > 3 ? '...' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage() {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: recipe.image.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: recipe.image,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppConstants.backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 40,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = AppConstants.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDietChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class RecipeListCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;

  const RecipeListCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // Recipe image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: recipe.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recipe.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppConstants.backgroundColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppConstants.primaryColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        )
                      : Container(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: AppConstants.defaultPadding),
              
              // Recipe details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.cookTimeText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Icon(
                          Icons.restaurant,
                          size: 16,
                          color: AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} servings',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    Row(
                      children: [
                        _buildDifficultyChip(recipe.difficultyLevel),
                        const Spacer(),
                        if (recipe.vegetarian) _buildDietIcon(Icons.eco, Colors.green),
                        if (recipe.vegan) _buildDietIcon(Icons.local_florist, Colors.lightGreen),
                        if (recipe.glutenFree) _buildDietIcon(Icons.no_food, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorite button
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.red : AppConstants.textSecondaryColor,
                ),
                onPressed: onFavoritePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = AppConstants.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDietIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Icon(icon, size: 16, color: color),
    );
  }
}