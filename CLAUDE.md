# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based recipe inventory application with gamification features, AI-powered recommendations, and YouTube recipe extraction capabilities. The app uses Firebase for backend services, Hive for local storage, and integrates with a custom FastAPI service for YouTube subtitle extraction.

## Essential Commands

### Flutter Development
```bash
# Install dependencies
flutter pub get

# Generate code for Freezed models (required after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
flutter pub run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run

# Analyze code quality
flutter analyze

# Run tests
flutter test

# Format code
flutter format lib/
```

### Platform-Specific
```bash
# iOS setup
cd ios && pod install

# Clean build artifacts
flutter clean
```

### API Service (in api/ directory)
```bash
# Install Python dependencies
pip install -r requirements.txt

# Run the FastAPI server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## Architecture Overview

### State Management
The app uses Provider pattern with dedicated status classes:
- `UserStatus`: User profile and authentication state
- `FoodStatus`: Food inventory management with expiration tracking
- `RecipeStatus`: Recipe data and wishlist management
- `QuestStatus`: Daily quests and progress tracking
- `BadgeStatus`: Achievement system management

Status classes communicate via callbacks, e.g., `FoodStatus` notifies `QuestStatus` and `BadgeStatus` when food items change.

### Data Layer
1. **Local Storage**: Hive database with type adapters for offline-first functionality
2. **Remote Storage**: Firebase Firestore for cloud sync
3. **Models**: Freezed immutable models with JSON serialization
4. **Migration**: `MigrationService` handles data schema updates

### Key Patterns
1. **Component Architecture**: Screens use `_component` files for major UI sections
2. **Service Layer**: Core services in `services/` handle external integrations
3. **Widget Reusability**: Common UI elements in `widgets/`
4. **Route Management**: GoRouter with named routes in `router.dart`

## Important Development Notes

### Code Generation
After modifying any Freezed model in `lib/models/freezed/`:
1. Run `flutter pub run build_runner build --delete-conflicting-outputs`
2. Commit both the model file and generated `.freezed.dart` and `.g.dart` files

### Firebase Integration
The app requires proper Firebase configuration:
- Android: `android/app/google-services.json`
- iOS: Firebase configuration in iOS project
- Services used: Authentication, Firestore, AdMob

### AI Features
- **Gemini Service**: Recipe recommendations based on available ingredients
- **ML Kit**: Text recognition for receipt scanning
- **YouTube API**: Recipe extraction from video subtitles

### Asset Management
- Food images organized by category in `assets/imgs/foods/`
- Badge images in `assets/imgs/badge/` with enabled/disabled variants
- Custom fonts: Mapo and Nanum families

### Testing Approach
When adding new features:
1. Test state management logic in status classes
2. Verify Hive database operations
3. Check Firebase sync functionality
4. Test UI components with different states

### Common Development Tasks

#### Adding a New Recipe Feature
1. Update `Recipe` model if needed
2. Modify `RecipeStatus` for state management
3. Update relevant screens/components
4. Run code generation for model changes

#### Adding a New Quest Type
1. Update `Quest` model in `lib/models/freezed/quest_model.dart`
2. Add quest logic in `QuestStatus`
3. Update `questData.dart` with new quest definitions
4. Test quest completion triggers

#### Modifying Food Categories
1. Update `FoodCategory` enum in food model
2. Add corresponding images in `assets/imgs/foods/`
3. Update food selection UI components

### API Endpoints
The YouTube subtitle extraction API provides:
- `POST /extract_subtitles`: Extract recipe from YouTube URL
- Returns structured recipe data with ingredients and steps

## Current Development Status

Recent work includes:
- Custom recipe creation and management features
- Drag-and-drop functionality for recipe steps
- Badge collection system implementation
- Quest system with daily challenges
- Advertisement integration (interstitial and rewarded ads)