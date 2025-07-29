import 'package:flutter/material.dart';
import 'package:find_my_reciepe/models/ingredient.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final bool isCompact;

  const IngredientCard({
    super.key,
    required this.ingredient,
    this.onTap,
    this.onDelete,
    this.showDeleteButton = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  Widget _buildFullCard() {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and delete button
              Row(
                children: [
                  _buildCategoryIcon(),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showDeleteButton)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppConstants.errorColor,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              
              const SizedBox(height: AppConstants.smallPadding),
              
              // Category and quantity
              Row(
                children: [
                  _buildCategoryChip(),
                  const Spacer(),
                  Text(
                    ingredient.quantity,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.smallPadding),
              
              // Expiry information
              if (ingredient.expiryDate != null)
                _buildExpiryInfo()
              else
                const SizedBox(height: 20),
              
              // Additional info
              Row(
                children: [
                  if (ingredient.isFromBarcode)
                    _buildInfoChip(Icons.qr_code, 'Scanned', AppConstants.accentColor),
                  const Spacer(),
                  Text(
                    _formatAddedDate(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard() {
    return Card(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryIcon(),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                ingredient.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (ingredient.isExpiringSoon || ingredient.isExpired)
                Icon(
                  Icons.warning,
                  size: 16,
                  color: ingredient.isExpired 
                      ? AppConstants.errorColor 
                      : AppConstants.warningColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData icon;
    Color color;
    
    switch (ingredient.category) {
      case 'Vegetables':
        icon = Icons.eco;
        color = Colors.green;
        break;
      case 'Fruits':
        icon = Icons.apple;
        color = Colors.orange;
        break;
      case 'Meat & Poultry':
        icon = Icons.set_meal;
        color = Colors.red;
        break;
      case 'Seafood':
        icon = Icons.set_meal;
        color = Colors.blue;
        break;
      case 'Dairy & Eggs':
        icon = Icons.local_drink;
        color = Colors.indigo;
        break;
      case 'Grains & Cereals':
        icon = Icons.grain;
        color = Colors.brown;
        break;
      case 'Legumes & Nuts':
        icon = Icons.scatter_plot;
        color = Colors.deepOrange;
        break;
      case 'Herbs & Spices':
        icon = Icons.local_florist;
        color = Colors.green;
        break;
      case 'Oils & Condiments':
        icon = Icons.opacity;
        color = Colors.amber;
        break;
      case 'Beverages':
        icon = Icons.local_cafe;
        color = Colors.cyan;
        break;
      case 'Frozen Foods':
        icon = Icons.ac_unit;
        color = Colors.lightBlue;
        break;
      case 'Canned Foods':
        icon = Icons.inventory;
        color = Colors.grey;
        break;
      case 'Bakery':
        icon = Icons.bakery_dining;
        color = Colors.orange;
        break;
      case 'Snacks':
        icon = Icons.cookie;
        color = Colors.deepPurple;
        break;
      default:
        icon = Icons.kitchen;
        color = AppConstants.textSecondaryColor;
    }

    return Container(
      width: isCompact ? 32 : 40,
      height: isCompact ? 32 : 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
      ),
      child: Icon(
        icon,
        color: color,
        size: isCompact ? 16 : 20,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ingredient.category,
        style: const TextStyle(
          fontSize: 12,
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExpiryInfo() {
    if (ingredient.expiryDate == null) return const SizedBox();

    final daysUntilExpiry = ingredient.expiryDate!.difference(DateTime.now()).inDays;
    final isExpired = ingredient.isExpired;
    final isExpiringSoon = ingredient.isExpiringSoon;

    Color color;
    IconData icon;
    String text;

    if (isExpired) {
      color = AppConstants.errorColor;
      icon = Icons.error;
      text = 'Expired ${daysUntilExpiry.abs()} days ago';
    } else if (isExpiringSoon) {
      color = AppConstants.warningColor;
      icon = Icons.warning;
      text = 'Expires in $daysUntilExpiry days';
    } else {
      color = AppConstants.successColor;
      icon = Icons.check_circle;
      text = 'Fresh ($daysUntilExpiry days left)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddedDate() {
    final now = DateTime.now();
    final difference = now.difference(ingredient.addedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class IngredientListTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const IngredientListTile({
    super.key,
    required this.ingredient,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
      child: ListTile(
        leading: _buildCategoryIcon(),
        title: Text(
          ingredient.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ingredient.category} • ${ingredient.quantity}',
              style: const TextStyle(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            if (ingredient.expiryDate != null)
              _buildExpiryText(),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: AppConstants.errorColor),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppConstants.errorColor)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData icon;
    Color color;
    
    switch (ingredient.category) {
      case 'Vegetables':
        icon = Icons.eco;
        color = Colors.green;
        break;
      case 'Fruits':
        icon = Icons.apple;
        color = Colors.orange;
        break;
      case 'Meat & Poultry':
        icon = Icons.set_meal;
        color = Colors.red;
        break;
      case 'Dairy & Eggs':
        icon = Icons.local_drink;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.kitchen;
        color = AppConstants.textSecondaryColor;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildExpiryText() {
    if (ingredient.expiryDate == null) return const SizedBox();

    final isExpired = ingredient.isExpired;
    final isExpiringSoon = ingredient.isExpiringSoon;
    final daysUntilExpiry = ingredient.expiryDate!.difference(DateTime.now()).inDays;

    Color color;
    String text;

    if (isExpired) {
      color = AppConstants.errorColor;
      text = 'Expired ${daysUntilExpiry.abs()} days ago';
    } else if (isExpiringSoon) {
      color = AppConstants.warningColor;
      text = 'Expires in $daysUntilExpiry days';
    } else {
      color = AppConstants.successColor;
      text = 'Fresh ($daysUntilExpiry days left)';
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}