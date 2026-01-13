# Dylan Step Count - Flutter

A Flutter-based step counter application that tracks daily steps using the device's sensors.

## Features

- Real-time step count monitoring using phone sensors
- Daily/weekly/monthly step statistics and display
- Step goal setting and completion tracking
- Data persistence using shared preferences

## Screenshots

![Step Counter Screen](screenshots/step_counter.png)

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android device or emulator for testing

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd dylan_step_count_flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```
### Using Tencent Cloud Mirrors (China)

For faster dependency downloads in China, you can use the Tencent Cloud Flutter/Dart mirrors:

```bash
export PUB_HOSTED_URL=https://mirrors.cloud.tencent.com/dart-pub
export FLUTTER_STORAGE_BASE_URL=https://mirrors.cloud.tencent.com/flutter
flutter pub get
```

On Windows CMD:
```cmd
set PUB_HOSTED_URL=https://mirrors.cloud.tencent.com/dart-pub
set FLUTTER_STORAGE_BASE_URL=https://mirrors.cloud.tencent.com/flutter
flutter pub get
```

On Windows PowerShell:
```powershell
$env:PUB_HOSTED_URL="https://mirrors.cloud.tencent.com/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL="https://mirrors.cloud.tencent.com/flutter"
flutter pub get
```

### Building APK

To build a release APK:

```bash
flutter build apk --release
```

The APK will be generated in `build/app/outputs/flutter-apk/app-release.apk`

### Permissions

The app requires the following permissions on Android:
- `ACTIVITY_RECOGNITION` - To access step counter sensor

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── step_counter_service.dart # Step counting logic
└── step_counter_screen.dart  # UI implementation
```

## Dependencies

- `pedometer: ^4.1.1` - For step counting functionality
- `shared_preferences: ^2.3.2` - For data persistence
- `intl: ^0.19.0` - For date formatting

## Features Implementation

### Step Counting
The app uses the `pedometer` package to access the device's step counter sensor for real-time step tracking.

### Data Persistence
Step data is stored locally using `shared_preferences` to maintain step counts across app sessions.

### Statistics
The app tracks and displays:
- Today's steps
- Weekly steps (last 7 days)
- Monthly steps
- Recent days history

### Goal Setting
Users can set daily step goals through the settings icon in the app bar. Progress toward the goal is displayed as a progress bar and percentage.

## Troubleshooting

### Gradle Issues
If you encounter Gradle-related issues:
1. Try running `flutter clean` and then `flutter pub get`
2. Ensure you have a stable internet connection for downloading dependencies
3. Check that your Android SDK is properly configured

### Sensor Permissions
On Android 10 and above, the app may need to request permission at runtime. Make sure to grant the activity recognition permission when prompted.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to the Flutter team for the excellent framework
- Thanks to the pedometer package maintainers
