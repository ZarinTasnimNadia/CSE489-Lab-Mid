# Landmark - Landmark Management App

A feature-rich Flutter application for discovering, managing, and visualizing landmarks with an interactive map interface and persistent data storage.

## App Summary

**Landmark** is a mobile application designed for users to efficiently manage geographical landmarks and points of interest. The app integrates OpenStreetMap-based visualization with a RESTful backend API to provide a seamless experience for creating, viewing, editing, and deleting landmark entries. Built with Flutter, it offers a beautiful, responsive UI with support for both light and dark themes.

The app allows users to:
- View landmarks on an interactive map centered on Bangladesh
- Browse all landmarks in a scrollable list view
- Create new landmark entries with images and metadata
- Edit existing landmark information
- Delete landmarks with confirmation
- Toggle between light and dark themes for comfortable viewing

## Features

✨ **Interactive Map Visualization**
- OpenStreetMap integration with flutter_map
- Real-time marker placement for all landmarks
- Tap markers to view and manage landmark details
- Auto-centered on Bangladesh coordinates

📋 **Landmarks Management**
- View all landmarks in a clean list view
- Create new landmark entries with title, description, and location
- Edit existing landmarks with pre-populated data
- Delete landmarks with confirmation dialogs
- Real-time data synchronization with backend API

🎨 **Customizable UI**
- Light and dark theme support
- Responsive design for various screen sizes
- Clean, modern interface using Material Design
- Custom color palette (purple/magenta theme)

📸 **Media Handling**
- Image picker integration for landmark photos
- Image compression and optimization

🌐 **Backend Integration**
- RESTful API communication via HTTP
- Fetch landmarks from remote server
- Create, update, and delete operations with backend synchronization

## Setup Instructions

### Prerequisites
- Flutter SDK (^3.10.3 or higher)
- Dart SDK (included with Flutter)
- Android SDK for Android development (API 21+)
- iOS deployment target 11.0+ (for iOS development)
- Git

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ZarinTasnimNadia/CSE489-Lab-Mid.git
   cd landmark
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Android (if developing for Android):**
   - Ensure Android SDK is installed and configured
   - Review `android/local.properties` to verify SDK paths

4. **Configure iOS (if developing for iOS):**
   ```bash
   cd ios
   pod repo update
   pod install
   cd ..
   ```

5. **Run the application:**
   ```bash
   flutter run
   ```
   
   For a specific device or platform:
   ```bash
   flutter run -d <device-id>              # Specific device
   flutter run -d web                      # Web platform
   flutter run -d linux                    # Linux platform
   ```

6. **Build for release:**
   ```bash
   flutter build apk                       # Android APK
   flutter build ios                       # iOS build
   flutter build web                       # Web build
   ```

### Project Structure
```
landmark/
├── lib/
│   ├── main.dart                 # App entry point and theme setup
│   ├── navigator.dart            # Navigation logic
│   ├── theme_logic.dart          # Theme provider (light/dark)
│   ├── api_service.dart          # Backend API communication
│   ├── landmark.dart             # Landmark data model
│   ├── landmark_edit_form.dart   # Landmark edit form widget
│   └── pages/
│       ├── overview.dart         # Map view with landmarks
│       ├── records.dart          # List view of all landmarks
│       └── new_entry.dart        # New landmark entry form
├── assets/
│   └── icons/                    # SVG icons
├── android/                      # Android-specific configuration
├── ios/                          # iOS-specific configuration
├── web/                          # Web-specific configuration
├── linux/                        # Linux-specific configuration
├── windows/                      # Windows-specific configuration
└── pubspec.yaml                  # Project dependencies
```

## Known Limitations

⚠️ **Current Limitations:**

1. **Offline Functionality**
   - The app requires an active internet connection to fetch and synchronize landmarks with the backend server
   - No local caching or offline mode currently implemented

2. **Authentication**
   - No user authentication or authorization system implemented
   - All landmarks are publicly visible and editable

3. **Data Validation**
   - Limited input validation on landmark creation/editing
   - No duplicate detection for landmarks

4. **Performance**
   - Performance may degrade with very large numbers of landmarks (100+)
   - Image loading on maps could be optimized further

5. **Marker Selection**
   - Multiple marker at the same area makes it hard to specifically select one marker

6. **Image Edit**
   - In edit option, updating an image of a landmark fails and in New Entry page updating an image duplicates the landmark with the new image and add as a new entry keeping the old landmark unchanged


---

**For more information, issues, or contributions, please visit the [GitHub repository](https://github.com/ZarinTasnimNadia/CSE489-Lab-Mid).**
