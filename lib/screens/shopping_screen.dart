import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_my_reciepe/providers/app_provider.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // TODO: Clear completed items
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final items = appProvider.shoppingItems;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppConstants.textSecondaryColor,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  const Text(
                    'Your shopping list is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  const Text(
                    'Items will appear here when you find recipes',
                    style: TextStyle(color: AppConstants.textSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return CheckboxListTile(
                title: Text(item.name),
                subtitle: Text('${item.quantity} • ${item.category}'),
                value: item.isCompleted,
                onChanged: (value) {
                  appProvider.toggleShoppingItemCompleted(index);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    appProvider.deleteShoppingItem(index);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}