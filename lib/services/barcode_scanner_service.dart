import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:find_my_reciepe/models/ingredient.dart';
import 'package:find_my_reciepe/constants/app_constants.dart';

class BarcodeScannerService {
  static final BarcodeScannerService _instance = BarcodeScannerService._internal();
  factory BarcodeScannerService() => _instance;
  BarcodeScannerService._internal();

  MobileScannerController? _controller;

  MobileScannerController createController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    return _controller!;
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  Future<Ingredient?> processBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty) return null;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;
    
    if (code == null || code.isEmpty) return null;

    // Try to get product information from barcode
    final productInfo = await _getProductInfoFromBarcode(code);
    
    if (productInfo != null) {
      return Ingredient(
        name: productInfo['name']!,
        category: productInfo['category']!,
        quantity: '1',
        isFromBarcode: true,
        barcode: code,
      );
    }

    return null;
  }

  Future<Map<String, String>?> _getProductInfoFromBarcode(String barcode) async {
    // In a real app, you would call a product database API like:
    // - Open Food Facts API
    // - UPC Database API
    // - Barcode Lookup API
    
    // For now, we'll use a mock database with common products
    final mockDatabase = _getMockProductDatabase();
    
    if (mockDatabase.containsKey(barcode)) {
      return mockDatabase[barcode];
    }

    // If not found in mock database, try to infer from barcode prefix
    return _inferProductFromBarcodePrefix(barcode);
  }

  Map<String, Map<String, String>> _getMockProductDatabase() {
    return {
      // Common grocery items (using made-up barcodes for demo)
      '1234567890123': {
        'name': 'Whole Milk',
        'category': 'Dairy & Eggs',
      },
      '2345678901234': {
        'name': 'White Bread',
        'category': 'Bakery',
      },
      '3456789012345': {
        'name': 'Cheddar Cheese',
        'category': 'Dairy & Eggs',
      },
      '4567890123456': {
        'name': 'Ground Beef',
        'category': 'Meat & Poultry',
      },
      '5678901234567': {
        'name': 'Chicken Breast',
        'category': 'Meat & Poultry',
      },
      '6789012345678': {
        'name': 'Bananas',
        'category': 'Fruits',
      },
      '7890123456789': {
        'name': 'Tomatoes',
        'category': 'Vegetables',
      },
      '8901234567890': {
        'name': 'Olive Oil',
        'category': 'Oils & Condiments',
      },
      '9012345678901': {
        'name': 'Rice',
        'category': 'Grains & Cereals',
      },
      '0123456789012': {
        'name': 'Pasta',
        'category': 'Grains & Cereals',
      },
      // Coca-Cola (real barcode example)
      '049000028058': {
        'name': 'Coca-Cola',
        'category': 'Beverages',
      },
      // Lay's Potato Chips (real barcode example)
      '028400047685': {
        'name': 'Lay\'s Potato Chips',
        'category': 'Snacks',
      },
      // Campbell's Tomato Soup (real barcode example)
      '051000012340': {
        'name': 'Campbell\'s Tomato Soup',
        'category': 'Canned Foods',
      },
    };
  }

  Map<String, String>? _inferProductFromBarcodePrefix(String barcode) {
    // This is a simplified approach - in reality, barcode prefixes
    // indicate the country of origin, not product type
    
    if (barcode.length < 12) return null;

    // Some basic inference based on common patterns
    // This is just for demo purposes
    final prefix = barcode.substring(0, 3);
    
    switch (prefix) {
      case '049': // Often beverages in US
        return {
          'name': 'Beverage Item',
          'category': 'Beverages',
        };
      case '028': // Often snacks in US
        return {
          'name': 'Snack Item',
          'category': 'Snacks',
        };
      case '051': // Often canned goods in US
        return {
          'name': 'Canned Item',
          'category': 'Canned Foods',
        };
      default:
        return {
          'name': 'Unknown Product',
          'category': 'Other',
        };
    }
  }

  // Helper method to validate barcode format
  bool isValidBarcode(String barcode) {
    // Check if it's a valid UPC-A (12 digits) or EAN-13 (13 digits)
    if (barcode.length != 12 && barcode.length != 13) {
      return false;
    }
    
    // Check if all characters are digits
    return RegExp(r'^\d+$').hasMatch(barcode);
  }

  // Method to manually add a barcode-ingredient mapping
  void addBarcodeMapping(String barcode, String name, String category) {
    // In a real app, this would be saved to local storage or synced to a server
    // For now, we'll just print it for debugging
    print('Added barcode mapping: $barcode -> $name ($category)');
  }

  // Get product suggestions based on partial barcode
  List<Map<String, String>> getProductSuggestions(String partialBarcode) {
    final mockDatabase = _getMockProductDatabase();
    final suggestions = <Map<String, String>>[];
    
    for (var entry in mockDatabase.entries) {
      if (entry.key.startsWith(partialBarcode)) {
        suggestions.add({
          'barcode': entry.key,
          'name': entry.value['name']!,
          'category': entry.value['category']!,
        });
      }
    }
    
    return suggestions;
  }

  // Mock method to simulate API call to product database
  Future<Map<String, dynamic>?> fetchProductFromAPI(String barcode) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // This would normally call an external API like:
    // https://world.openfoodfacts.org/api/v0/product/{barcode}.json
    
    // For demo, return mock data
    final mockDatabase = _getMockProductDatabase();
    if (mockDatabase.containsKey(barcode)) {
      return {
        'product_name': mockDatabase[barcode]!['name'],
        'categories': mockDatabase[barcode]!['category'],
        'image_url': null,
        'brands': 'Generic Brand',
        'quantity': '1 unit',
      };
    }
    
    return null;
  }

  // Convert API response to Ingredient
  Ingredient? createIngredientFromAPIResponse(
    String barcode, 
    Map<String, dynamic> apiResponse
  ) {
    try {
      final name = apiResponse['product_name'] as String?;
      if (name == null || name.isEmpty) return null;
      
      final categories = apiResponse['categories'] as String?;
      final category = _mapAPICategoriesToAppCategory(categories);
      
      return Ingredient(
        name: name,
        category: category,
        quantity: '1',
        isFromBarcode: true,
        barcode: barcode,
        imageUrl: apiResponse['image_url'] as String?,
      );
    } catch (e) {
      print('Error creating ingredient from API response: $e');
      return null;
    }
  }

  String _mapAPICategoriesToAppCategory(String? apiCategories) {
    if (apiCategories == null) return 'Other';
    
    final categories = apiCategories.toLowerCase();
    
    if (categories.contains('dairy') || categories.contains('milk') || 
        categories.contains('cheese') || categories.contains('yogurt')) {
      return 'Dairy & Eggs';
    } else if (categories.contains('meat') || categories.contains('poultry') || 
               categories.contains('chicken') || categories.contains('beef')) {
      return 'Meat & Poultry';
    } else if (categories.contains('vegetable') || categories.contains('produce')) {
      return 'Vegetables';
    } else if (categories.contains('fruit')) {
      return 'Fruits';
    } else if (categories.contains('beverage') || categories.contains('drink')) {
      return 'Beverages';
    } else if (categories.contains('snack') || categories.contains('chip')) {
      return 'Snacks';
    } else if (categories.contains('canned') || categories.contains('preserved')) {
      return 'Canned Foods';
    } else if (categories.contains('bread') || categories.contains('bakery')) {
      return 'Bakery';
    } else if (categories.contains('cereal') || categories.contains('grain') || 
               categories.contains('rice') || categories.contains('pasta')) {
      return 'Grains & Cereals';
    } else {
      return 'Other';
    }
  }
}