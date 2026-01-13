import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'step_count_foreground',
    'StepCounter',
    description: 'This channel is used for step counting background service.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'step_count_foreground',
      initialNotificationTitle: 'StepCounter', // This matches @string/app_name
      initialNotificationContent: '步数追踪服务已启动',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // CRITICAL: Send first signal IMMEDIATELY before anything else
  service.invoke('update', {"status": "Isolate Started"});

  try {
    DartPluginRegistrant.ensureInitialized();
    service.invoke('update', {"status": "Plugin Registrant OK"});

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Initialize notifications (potential hang point)
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_bg_service_small');
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await flutterLocalNotificationsPlugin
          .initialize(initializationSettings)
          .timeout(const Duration(seconds: 5));
      service.invoke('update', {"status": "Notifications OK"});
    } catch (e) {
      service.invoke('update', {"status": "Notif Init Error: $e"});
    }

    if (service is AndroidServiceInstance) {
      service
          .on('setAsForeground')
          .listen((event) => service.setAsForegroundService());
      service
          .on('setAsBackground')
          .listen((event) => service.setAsBackgroundService());
    }

    service.on('stopService').listen((event) => service.stopSelf());

    // UI Ping listener
    service.on('ping').listen((event) {
      service.invoke('update', {
        "status": "Pong",
        "timestamp": DateTime.now().toIso8601String(),
        "isServiceRunning": true,
      });
    });

    service.on('getData').listen((event) async {
       final prefs = await SharedPreferences.getInstance();
       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
       final steps = prefs.getInt('steps_today_$today') ?? 0;
       service.invoke('update', {
         "steps": steps,
         "date": today,
         "status": "Sync complete"
       });
    });

    StreamSubscription<StepCount>? stepSubscription;
    StreamSubscription<PedestrianStatus>? statusSubscription;
    String lastStatus = 'Ready';
    int lastSentSteps = -1;

    void startListening() {
      print("BGService: startListening called");
      stepSubscription?.cancel();
      statusSubscription?.cancel();

      service.invoke('update', {"status": "Sensing Start..."});

      try {
        stepSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) async {
            try {
              final prefs = await SharedPreferences.getInstance();
              final now = DateTime.now();
              final todayDate = DateFormat('yyyy-MM-dd').format(now);

              int totalAtStart = prefs.getInt('total_at_start_$todayDate') ?? -1;
              int accumulatedOffset = prefs.getInt('accumulated_offset_$todayDate') ?? 0;
              int lastTotal = prefs.getInt('last_total_steps') ?? 0;
              int lastTodaySteps = prefs.getInt('steps_today_$todayDate') ?? 0;

              // Sensor was zeroed or device rebooted
              if (totalAtStart == -1 || event.steps < lastTotal) {
                if (event.steps < lastTotal) {
                  accumulatedOffset = lastTodaySteps;
                }
                totalAtStart = event.steps;
                await prefs.setInt('total_at_start_$todayDate', totalAtStart);
                await prefs.setInt('accumulated_offset_$todayDate', accumulatedOffset);
              }

              int todaySteps = (event.steps - totalAtStart) + accumulatedOffset;
              if (todaySteps < 0) todaySteps = 0;

              await prefs.setInt('steps_today_$todayDate', todaySteps);
              await prefs.setInt('last_total_steps', event.steps);

              List<String> trackedDays = prefs.getStringList('tracked_days') ?? [];
              if (!trackedDays.contains(todayDate)) {
                trackedDays.add(todayDate);
                await prefs.setStringList('tracked_days', trackedDays);
              }

              // Update notification periodically or if steps changed significantly
              if (todaySteps != lastSentSteps) {
                lastSentSteps = todaySteps;
                if (service is AndroidServiceInstance) {
                  flutterLocalNotificationsPlugin.show(
                    888,
                    'StepCounter', // App name matching @string/app_name
                    '今日步数: $todaySteps',
                    const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'step_count_foreground',
                        'StepCounter', // Channel name matching app name
                        channelDescription: '步数追踪服务通知', // Channel description
                        icon: 'ic_bg_service_small', // Use generated consistent icon
                        ongoing: true,
                        importance: Importance.low,
                        priority: Priority.low,
                        showWhen: false,
                        onlyAlertOnce: true,
                      ),
                    ),
                  );
                }

                service.invoke('update', {
                  "steps": todaySteps,
                  "date": todayDate,
                  "status": "Counting",
                  "lastUpdate": now.toIso8601String(),
                });
              }
            } catch (e) {
              service.invoke('update', {"status": "Data Proc Error: $e"});
            }
          },
          onError: (error) {
            print("BGService: Step Error: $error");
            service.invoke('update', {"status": "Sensor Error: $error"});
          },
          onDone: () {
             service.invoke('update', {"status": "Sensor Stopped"});
          },
          cancelOnError: false,
        );

        statusSubscription = Pedometer.pedestrianStatusStream.listen(
          (PedestrianStatus event) {
            lastStatus = event.status;
            service.invoke('update', {"status": lastStatus});
          },
          onError: (error) {
            service.invoke('update', {"status": "Status Error: $error"});
          },
        );
      } catch (e) {
        service.invoke('update', {"status": "Init Error: $e"});
      }
    }

    service.on('startStepCounting').listen((event) => startListening());

    // Start immediately
    startListening();
    service.invoke('update', {"status": "Service Ready"});

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        service.invoke('update', {
          "heartbeat": DateTime.now().toIso8601String(),
          "isSensing": stepSubscription != null
        });
      } catch (_) {}
    });
  } catch (e) {
    try {
      service.invoke('update', {"status": "FATAL: $e"});
    } catch (_) {}
  }
}
