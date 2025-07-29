# 🥘 Find My Recipe

A Flutter-powered mobile application that helps users find recipes based on ingredients they have in their kitchen. Perfect for reducing food waste and discovering new meal ideas!

## ✨ Features

### 🔑 Core Features

- **📸 Ingredient Recognition**: Scan ingredients using camera or upload photos with Google ML Kit
- **🧾 Barcode Scanner**: Scan product barcodes to quickly add packaged items
- **✍️ Manual Entry**: Add ingredients manually with categories and expiry dates
- **🍽️ Smart Recipe Suggestions**: Get recipe recommendations based on available ingredients
- **🛒 Shopping List Generator**: Automatically create shopping lists for missing ingredients
- **📚 Favorites & Bookmarks**: Save and organize your favorite recipes
- **🔄 Pantry Management**: Track ingredients with expiry dates and categories
- **🔔 Smart Notifications**: Get alerts for expiring ingredients and recipe suggestions

### 🎨 UI/UX Features

- **Modern Material Design**: Clean, intuitive interface with smooth animations
- **Dark/Light Theme**: Automatic theme switching based on system preferences
- **Responsive Layout**: Optimized for different screen sizes
- **Offline Support**: Local data storage with Hive for offline functionality
- **Search & Filter**: Advanced filtering by cuisine, diet, cook time, and more

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | Flutter with Provider for state management |
| **Image Recognition** | Google ML Kit for ingredient identification |
| **Barcode Scanning** | mobile_scanner package |
| **API Integration** | Spoonacular API for recipe data |
| **Local Storage** | Hive for fast, lightweight data persistence |
| **Notifications** | flutter_local_notifications |
| **UI Components** | Material Design 3 with custom themes |
| **Image Caching** | cached_network_image for optimized loading |

## 📱 App Architecture

```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models (Ingredient, Recipe, ShoppingItem)
├── services/          # Business logic and API services
│   ├── recipe_api_service.dart
│   ├── image_recognition_service.dart
│   ├── barcode_scanner_service.dart
│   └── storage_service.dart
├── providers/         # State management with Provider
├── screens/           # UI screens
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── pantry_screen.dart
│   ├── recipes_screen.dart
│   ├── shopping_screen.dart
│   └── ingredient_scanner_screen.dart
└── widgets/           # Reusable UI components
    ├── recipe_card.dart
    └── ingredient_card.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smart-recipe-app.git
   cd smart-recipe-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure API Keys**
   - Get a free API key from [Spoonacular](https://spoonacular.com/food-api)
   - Update `lib/constants/app_constants.dart`:
   ```dart
   static const String spoonacularApiKey = 'YOUR_API_KEY_HERE';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Add camera permissions in `android/app/src/main/AndroidManifest.xml`

#### iOS
- Minimum deployment target: iOS 11.0
- Add camera usage description in `ios/Runner/Info.plist`

## 📊 Key Features Breakdown

### 🥦 Ingredient Management
- **Smart Categorization**: Automatic categorization of ingredients
- **Expiry Tracking**: Visual indicators for expiring/expired items
- **Quantity Management**: Track quantities with flexible units
- **Search & Filter**: Find ingredients quickly by name or category

### 🍽️ Recipe Discovery
- **Ingredient-Based Search**: Find recipes using available ingredients
- **Advanced Filters**: Filter by cuisine, diet, cooking time, difficulty
- **Recipe Details**: Complete ingredients list, instructions, and nutrition info
- **Favorites System**: Save and organize favorite recipes

### 🛒 Smart Shopping
- **Auto-Generated Lists**: Create shopping lists from recipe requirements
- **Missing Ingredients**: Identify what you need to buy
- **Category Organization**: Group items by store sections
- **Export Options**: Share lists via WhatsApp, email, or PDF

### 📱 User Experience
- **Onboarding Flow**: Smooth introduction to app features
- **Quick Actions**: Fast access to common tasks
- **Visual Feedback**: Loading states, success/error messages
- **Responsive Design**: Adapts to different screen sizes

## 🔧 Configuration

### API Configuration
The app uses the Spoonacular API for recipe data. To configure:

1. Sign up at [Spoonacular](https://spoonacular.com/food-api)
2. Get your API key
3. Update the constant in `lib/constants/app_constants.dart`

### Customization
- **Colors**: Modify theme colors in `app_constants.dart`
- **Categories**: Update ingredient categories list
- **Features**: Enable/disable features in app settings

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📈 Future Enhancements

- **🗣️ Voice Commands**: "Show me recipes with chicken and rice"
- **📊 Analytics Dashboard**: Usage statistics and cooking insights
- **🌐 Community Features**: Share recipes with other users
- **🤖 AI Meal Planning**: Weekly meal suggestions
- **🏪 Store Integration**: Direct shopping from partner stores
- **📱 Widget Support**: Home screen widgets for quick access

**Happy Cooking! 👨‍🍳👩‍🍳**
