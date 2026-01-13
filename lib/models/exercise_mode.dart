// 运动模式模型
class ExerciseMode {
  final String id;
  final String name;
  final String iconName;
  final ExerciseModeType type;
  final double caloriesPerStep; // 每步消耗的卡路里（相对于步行的倍数）
  final String description;

  const ExerciseMode({
    required this.id,
    required this.name,
    required this.iconName,
    required this.type,
    this.caloriesPerStep = 1.0,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'type': type.toString(),
      'caloriesPerStep': caloriesPerStep,
      'description': description,
    };
  }

  factory ExerciseMode.fromJson(Map<String, dynamic> json) {
    return ExerciseMode(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      type: ExerciseModeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ExerciseModeType.walking,
      ),
      caloriesPerStep: json['caloriesPerStep'] as double? ?? 1.0,
      description: json['description'] as String,
    );
  }
}

enum ExerciseModeType {
  walking,     // 步行
  running,     // 跑步
  cycling,     // 骑行
  hiking,      // 徒步/爬山
  swimming,    // 游泳
  custom,      // 自定义
}

// 运动记录
class ExerciseSession {
  final String id;
  final ExerciseModeType modeType;
  final int steps;
  final double distance; // 米
  final double calories;
  final Duration duration;
  final DateTime startTime;
  final DateTime? endTime;
  final List<LocationPoint> route; // GPS轨迹
  bool isActive;

  ExerciseSession({
    required this.id,
    required this.modeType,
    this.steps = 0,
    this.distance = 0,
    this.calories = 0,
    required this.duration,
    required this.startTime,
    this.endTime,
    this.route = const [],
    this.isActive = true,
  });

  double get avgSpeed => duration.inSeconds > 0 
      ? distance / duration.inSeconds // 米/秒
      : 0;

  double get avgPace => distance > 0 
      ? duration.inMinutes / (distance / 1000) // 分钟/公里
      : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modeType': modeType.toString(),
      'steps': steps,
      'distance': distance,
      'calories': calories,
      'duration': duration.inSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'route': route.map((p) => p.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      id: json['id'] as String,
      modeType: ExerciseModeType.values.firstWhere(
        (e) => e.toString() == json['modeType'],
        orElse: () => ExerciseModeType.walking,
      ),
      steps: json['steps'] as int? ?? 0,
      distance: json['distance'] as double? ?? 0,
      calories: json['calories'] as double? ?? 0,
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String)
          : null,
      route: (json['route'] as List?)
          ?.map((p) => LocationPoint.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

// GPS坐标点
class LocationPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime timestamp;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      altitude: json['altitude'] as double?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// 预定义运动模式
class ExerciseModes {
  static const walking = ExerciseMode(
    id: 'walking',
    name: '步行',
    iconName: 'directions_walk',
    type: ExerciseModeType.walking,
    caloriesPerStep: 1.0,
    description: '日常步行,轻松健康',
  );

  static const running = ExerciseMode(
    id: 'running',
    name: '跑步',
    iconName: 'directions_run',
    type: ExerciseModeType.running,
    caloriesPerStep: 2.0,
    description: '燃烧卡路里,提升心肺',
  );

  static const cycling = ExerciseMode(
    id: 'cycling',
    name: '骑行',
    iconName: 'directions_bike',
    type: ExerciseModeType.cycling,
    caloriesPerStep: 1.5,
    description: '低冲击有氧运动',
  );

  static const hiking = ExerciseMode(
    id: 'hiking',
    name: '徒步/爬山',
    iconName: 'terrain',
    type: ExerciseModeType.hiking,
    caloriesPerStep: 1.8,
    description: '挑战自我,征服高峰',
  );

  static const swimming = ExerciseMode(
    id: 'swimming',
    name: '游泳',
    iconName: 'pool',
    type: ExerciseModeType.swimming,
    caloriesPerStep: 2.5,
    description: '全身运动,关节友好',
  );

  static List<ExerciseMode> get all => [
    walking,
    running,
    cycling,
    hiking,
    swimming,
  ];
}
