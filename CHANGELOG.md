# Changelog

## [1.0.0] - 2025-09-14

### Added
- Initial release of Dylan Step Count Flutter application
- Real-time step count monitoring using phone sensors
- Daily/weekly/monthly step statistics and display
- Step goal setting and completion tracking
- Data persistence using shared preferences
- Clean and intuitive user interface

### Features
- **Step Counting**: Real-time step tracking using device sensors
- **Statistics**: View daily, weekly, and monthly step counts
- **Goal Setting**: Set daily step goals and track progress
- **Data Persistence**: Step data saved locally on the device
- **Responsive UI**: Clean and user-friendly interface

### Dependencies
- Flutter SDK 3.35.2
- pedometer 4.1.1
- shared_preferences 2.3.2
- intl 0.19.0

### Platform Support
- Android (primary target)
- Future support for iOS planned

### Known Issues
- Building APK may require proper Gradle setup
- Sensor permissions need to be granted on Android 10+