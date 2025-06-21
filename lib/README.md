# Besinova - Flutter App Architecture

This document describes the clean architecture structure of the Besinova Flutter application.

## Architecture Overview

The application follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                 # Core application layer
│   ├── constants/       # Application constants
│   ├── services/        # Core services
│   └── theme/          # Theme configuration
├── data/               # Data layer
│   ├── models/         # Data models
│   └── services/       # Data services
├── presentation/       # Presentation layer
│   ├── providers/      # State management
│   ├── screens/        # UI screens
│   └── widgets/        # Reusable widgets
└── main.dart          # Application entry point
```

## Layer Responsibilities

### Core Layer (`core/`)
- **Constants**: Application-wide constants, colors, sizes
- **Services**: Core services like localization
- **Theme**: Theme configuration and styling

### Data Layer (`data/`)
- **Models**: Data structures (User, Product)
- **Services**: Data access and business logic
  - `StorageService`: Local data persistence
  - `ProductService`: API operations
  - `BudgetOptimizationService`: Business logic

### Presentation Layer (`presentation/`)
- **Providers**: State management using Provider pattern
- **Screens**: UI screens and pages
- **Widgets**: Reusable UI components

## Key Features

### State Management
- Uses Provider pattern for state management
- `UserProvider`: Manages user data and preferences
- `ThemeProvider`: Manages application theme

### Data Persistence
- `StorageService`: Handles local data storage using SharedPreferences
- Proper error handling and type safety

### Constants Management
- Centralized constants for colors, sizes, and configuration
- Easy to maintain and modify

### Theme System
- Light and dark theme support
- Centralized theme configuration
- Consistent styling across the app

## Usage Examples

### Using Constants
```dart
import 'package:besinova/core/core.dart';

// Use app constants
final appName = AppConstants.appName;
final primaryColor = AppColors.deepFern;
final spacing = AppSizes.md;
```

### Using Services
```dart
import 'package:besinova/data/data.dart';

// Load user data
final user = await StorageService.loadUser();

// Fetch products
final products = await ProductService().fetchProducts();
```

### Using Providers
```dart
import 'package:besinova/presentation/presentation.dart';

// Access user data
final userProvider = Provider.of<UserProvider>(context);
final userName = userProvider.name;

// Update theme
final themeProvider = Provider.of<ThemeProvider>(context);
themeProvider.toggleTheme();
```

## Best Practices

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Dependency Injection**: Services are injected where needed
3. **Error Handling**: Proper error handling throughout the app
4. **Type Safety**: Strong typing with null safety
5. **Documentation**: Well-documented code with clear comments
6. **Constants**: No hardcoded values, use constants instead
7. **Clean Code**: Follow Dart/Flutter best practices

## Future Improvements

1. **Localization**: Implement proper localization using intl package
2. **Testing**: Add unit and widget tests
3. **API Layer**: Implement proper API layer with repositories
4. **Caching**: Add data caching mechanisms
5. **Analytics**: Add analytics and crash reporting
6. **CI/CD**: Set up continuous integration and deployment 