import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_my_reciepe/providers/app_provider.dart';
import 'package:find_my_reciepe/models/ingredient.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class IngredientScannerScreen extends StatefulWidget {
  const IngredientScannerScreen({super.key});

  @override
  State<IngredientScannerScreen> createState() => _IngredientScannerScreenState();
}

// class _IngredientScannerScreenState extends State<IngredientScannerScreen> {
//   int _selectedIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Ingredients'),
//         bottom: TabBar(
//           controller: TabController(length: 3, vsync: Scaffold.of(context)),
//           onTap: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           tabs: const [
//             Tab(icon: Icon(Icons.camera_alt), text: 'Camera'),
//             Tab(icon: Icon(Icons.qr_code_scanner), text: 'Barcode'),
//             Tab(icon: Icon(Icons.edit), text: 'Manual'),
//           ],
//         ),
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: const [
//           CameraScanTab(),
//           BarcodeScanTab(),
//           ManualEntryTab(),
//         ],
//       ),
//     );
//   }
// }
// class _IngredientScannerScreenState extends State<IngredientScannerScreen> with SingleTickerProviderStateMixin {
//   int _selectedIndex = 0;
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//         title: const Text('Add Ingredients'),
//     bottom: TabBar(
//     controller: _tabController,
//     onTap: (index) {
//     setState(() {
//     _selectedIndex = index;
//     });
//     },
//     tabs: const [
//     Tab(icon: Icon(Icons.camera_alt)),
//     Tab(icon: Icon(Icons.qr_code_scanner)),
//     Tab(icon: Icon(Icons.edit)),
//     ],
//     ),
//     ),
//     body: IndexedStack(
//     index: _selectedIndex,
//     children: const [
//     CameraScanTab(),
//     BarcodeScanTab(),
//     ManualEntryTab(),
//     ],
//     ),
//     );
//   }
// }

class _IngredientScannerScreenState extends State<IngredientScannerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Add Ingredients'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt), text: 'Camera'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Barcode'),
            Tab(icon: Icon(Icons.edit), text: 'Manual'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          CameraScanTab(),
          BarcodeScanTab(),
          ManualEntryTab(),
        ],
      ),
    );
  }
}

class CameraScanTab extends StatelessWidget {
  const CameraScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppConstants.primaryColor),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: AppConstants.primaryColor,
                      ),
                      SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'Camera Preview',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Point your camera at ingredients to identify them',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: appProvider.isLoading
                          ? null
                          : () => _takePicture(context, appProvider),
                      icon: appProvider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera),
                      label: Text(appProvider.isLoading ? 'Processing...' : 'Take Picture'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickFromGallery(context, appProvider),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _takePicture(BuildContext context, AppProvider appProvider) async {
    try {
      // Mock ingredient recognition
      final mockIngredients = [
        Ingredient(name: 'Tomato', category: 'Vegetables'),
        Ingredient(name: 'Onion', category: 'Vegetables'),
        Ingredient(name: 'Garlic', category: 'Vegetables'),
      ];

      for (var ingredient in mockIngredients) {
        await appProvider.addIngredient(ingredient);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${mockIngredients.length} ingredients'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan ingredients: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _pickFromGallery(BuildContext context, AppProvider appProvider) async {
    // Similar to _takePicture but for gallery
    _takePicture(context, appProvider);
  }
}

class BarcodeScanTab extends StatelessWidget {
  const BarcodeScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppConstants.accentColor),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: AppConstants.accentColor,
                      ),
                      SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'Barcode Scanner',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Scan product barcodes to add them to your pantry',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: appProvider.isLoading
                      ? null
                      : () => _scanBarcode(context, appProvider),
                  icon: appProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner),
                  label: Text(appProvider.isLoading ? 'Scanning...' : 'Scan Barcode'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scanBarcode(BuildContext context, AppProvider appProvider) async {
    try {
      // Mock barcode scanning
      final mockIngredient = Ingredient(
        name: 'Whole Milk',
        category: 'Dairy & Eggs',
        isFromBarcode: true,
        barcode: '1234567890123',
      );

      await appProvider.addIngredient(mockIngredient);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${mockIngredient.name}'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan barcode: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
}

class ManualEntryTab extends StatefulWidget {
  const ManualEntryTab({super.key});

  @override
  State<ManualEntryTab> createState() => _ManualEntryTabState();
}

class _ManualEntryTabState extends State<ManualEntryTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _selectedCategory = AppConstants.ingredientCategories.first;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Ingredient Manually',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.largePadding),
                
                // Ingredient name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient Name',
                    prefixIcon: Icon(Icons.local_grocery_store),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ingredient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: AppConstants.ingredientCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Quantity
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.scale),
                    hintText: 'e.g., 1 kg, 500g, 2 pieces',
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Expiry date
                InkWell(
                  onTap: () => _selectExpiryDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date (Optional)',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _expiryDate != null
                          ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                          : 'Select expiry date',
                      style: TextStyle(
                        color: _expiryDate != null
                            ? AppConstants.textPrimaryColor
                            : AppConstants.textSecondaryColor,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: appProvider.isLoading
                        ? null
                        : () => _addIngredient(context, appProvider),
                    icon: appProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(appProvider.isLoading ? 'Adding...' : 'Add Ingredient'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _addIngredient(BuildContext context, AppProvider appProvider) async {
    if (_formKey.currentState!.validate()) {
      try {
        final ingredient = Ingredient(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          quantity: _quantityController.text.trim(),
          expiryDate: _expiryDate,
        );

        await appProvider.addIngredient(ingredient);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${ingredient.name}'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add ingredient: $e'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }
}