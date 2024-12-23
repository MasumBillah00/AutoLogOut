// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'bloc/auth_bloc.dart';
// import 'bloc/auth_event.dart';
//
// class InactivityListener extends StatefulWidget {
//   final Widget child;
//   final Duration timeoutDuration;
//   final Duration gracePeriodDuration;
//   final ValueNotifier<int> inactivityTimerNotifier;
//   final ValueNotifier<int> graceTimerNotifier;
//
//   const InactivityListener({
//     super.key,
//     required this.child,
//     required this.inactivityTimerNotifier,
//     required this.graceTimerNotifier,
//     this.timeoutDuration = const Duration(seconds: 10),
//     this.gracePeriodDuration = const Duration(seconds: 10),
//   });
//
//   @override
//   _InactivityListenerState createState() => _InactivityListenerState();
// }
//
// class _InactivityListenerState extends State<InactivityListener> {
//   Timer? _inactivityTimer;
//   Timer? _gracePeriodTimer;
//   int _remainingInactivitySeconds = 0;
//   int _remainingGraceSeconds = 0;
//   bool _isGracePeriodActive = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _startInactivityTimer();
//   }
//
//   @override
//   void dispose() {
//     _inactivityTimer?.cancel();
//     _gracePeriodTimer?.cancel();
//     super.dispose();
//   }
//
//   void _startInactivityTimer() {
//     _cancelInactivityTimer();
//     //print('set new time');
//     _remainingInactivitySeconds = widget.timeoutDuration.inSeconds;
//     _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingInactivitySeconds > 0) {
//         _remainingInactivitySeconds--;
//         widget.inactivityTimerNotifier.value = _remainingInactivitySeconds;
//       } else {
//         timer.cancel();
//         _handleInactivity();
//       }
//     });
//   }
//
//   void _handleInactivity() {
//     _startGracePeriod();
//   }
//
//   void _startGracePeriod() {
//     setState(() {
//       _isGracePeriodActive = true;
//     });
//     //print('start grace timer');
//
//     _remainingGraceSeconds = widget.gracePeriodDuration.inSeconds;
//     widget.graceTimerNotifier.value = _remainingGraceSeconds;
//
//     _gracePeriodTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingGraceSeconds > 0) {
//         _remainingGraceSeconds--;
//         widget.graceTimerNotifier.value = _remainingGraceSeconds;
//       } else {
//         timer.cancel();
//         _performLogout();
//       }
//     });
//   }
//
//   void _performLogout() {
//     BlocProvider.of<AuthBloc>(context).add(AutoLogoutEvent());
//   }
//
//   void _resetInactivityTimer() {
//     _startInactivityTimer();
//     if (_isGracePeriodActive) {
//       _cancelGracePeriodTimer();
//     }
//   }
//
//   void _cancelInactivityTimer() {
//     _inactivityTimer?.cancel();
//   }
//
//   void _cancelGracePeriodTimer() {
//     _gracePeriodTimer?.cancel();
//     setState(() {
//       _isGracePeriodActive = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: _resetInactivityTimer,
//       onPanDown: (_) => _resetInactivityTimer(),
//       child: widget.child,
//     );
//   }
// }
//
// class TimerDisplay extends StatelessWidget {
//   final ValueNotifier<int> inactivityTimerNotifier;
//   final ValueNotifier<int> graceTimerNotifier;
//
//   const TimerDisplay({
//     super.key,
//     required this.inactivityTimerNotifier,
//     required this.graceTimerNotifier,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 130,
//       height: 60,
//       padding: const EdgeInsets.all(1.0),
//       child: Card(
//
//         color:Colors.blueGrey.shade900,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ValueListenableBuilder<int>(
//               valueListenable: inactivityTimerNotifier,
//               builder: (context, value, child) {
//                 return Text(
//                   'Inactivity: $value s',
//                   style: const TextStyle(color: Colors.white),
//                 );
//               },
//             ),
//             ValueListenableBuilder<int>(
//               valueListenable: graceTimerNotifier,
//               builder: (context, value, child) {
//                 return Text(
//                   'Grace: $value s',
//                   style: const TextStyle(color: Colors.white),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





//*************SOLUTION WITHOUT PACKAGE*******//


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'bloc/auth_bloc.dart';
// import 'bloc/auth_event.dart';
//
// class InactivityListener extends StatefulWidget {
//   final Widget child;
//   final Duration timeoutDuration;
//   final Duration gracePeriodDuration;
//   final ValueNotifier<int> inactivityTimerNotifier;
//   final ValueNotifier<int> graceTimerNotifier;
//
//   const InactivityListener({
//     super.key,
//     required this.child,
//     required this.inactivityTimerNotifier,
//     required this.graceTimerNotifier,
//     this.timeoutDuration = const Duration(seconds: 10),
//     this.gracePeriodDuration = const Duration(seconds: 10),
//   });
//
//   @override
//   InactivityListenerState createState() => InactivityListenerState();
// }
//
// class InactivityListenerState extends State<InactivityListener> with WidgetsBindingObserver {
//   Timer? _inactivityTimer;
//   Timer? _gracePeriodTimer;
//   DateTime? _lastPausedTime;
//   int _remainingInactivitySeconds = 0;
//   int _remainingGraceSeconds = 0;
//   bool _isGracePeriodActive = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _startInactivityTimer();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _inactivityTimer?.cancel();
//     _gracePeriodTimer?.cancel();
//     super.dispose();
//   }
//
//   void _startInactivityTimer() {
//     _cancelInactivityTimer();
//     _remainingInactivitySeconds = widget.timeoutDuration.inSeconds;
//     _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingInactivitySeconds > 0) {
//         _remainingInactivitySeconds--;
//         widget.inactivityTimerNotifier.value = _remainingInactivitySeconds;
//       } else {
//         timer.cancel();
//         _handleInactivity();
//       }
//     });
//   }
//
//   void _handleInactivity() {
//     _startGracePeriod();
//   }
//
//   void _startGracePeriod() {
//     setState(() {
//       _isGracePeriodActive = true;
//     });
//
//     _remainingGraceSeconds = widget.gracePeriodDuration.inSeconds;
//     widget.graceTimerNotifier.value = _remainingGraceSeconds;
//
//     _gracePeriodTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingGraceSeconds > 0) {
//         _remainingGraceSeconds--;
//         widget.graceTimerNotifier.value = _remainingGraceSeconds;
//       } else {
//         timer.cancel();
//         _performLogout();
//       }
//     });
//   }
//
//   void _performLogout() {
//     BlocProvider.of<AuthBloc>(context).add(AutoLogoutEvent());
//   }
//
//   void _resetInactivityTimer() {
//     _startInactivityTimer();
//     if (_isGracePeriodActive) {
//       _cancelGracePeriodTimer();
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       // App is in the background
//       _lastPausedTime = DateTime.now();
//     } else if (state == AppLifecycleState.resumed) {
//       // App resumed - calculate time spent in background
//       if (_lastPausedTime != null) {
//         final durationInBackground = DateTime.now().difference(_lastPausedTime!);
//         if (durationInBackground >= widget.timeoutDuration) {
//           _handleInactivity();
//         }
//       }
//     }
//   }
//
//   void _cancelInactivityTimer() {
//     _inactivityTimer?.cancel();
//   }
//
//   void _cancelGracePeriodTimer() {
//     _gracePeriodTimer?.cancel();
//     setState(() {
//       _isGracePeriodActive = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: _resetInactivityTimer,
//       onPanDown: (_) => _resetInactivityTimer(),
//       child: widget.child,
//     );
//   }
// }
//
//
// class TimerDisplay extends StatelessWidget {
//   final ValueNotifier<int> inactivityTimerNotifier;
//   final ValueNotifier<int> graceTimerNotifier;
//
//   const TimerDisplay({
//     super.key,
//     required this.inactivityTimerNotifier,
//     required this.graceTimerNotifier,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 130,
//       height: 60,
//       padding: const EdgeInsets.all(1.0),
//       child: Card(
//
//         color:Colors.blueGrey.shade900,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ValueListenableBuilder<int>(
//               valueListenable: inactivityTimerNotifier,
//               builder: (context, value, child) {
//                 return Text(
//                   'Inactivity: $value s',
//                   style: const TextStyle(color: Colors.white),
//                 );
//               },
//             ),
//             ValueListenableBuilder<int>(
//               valueListenable: graceTimerNotifier,
//               builder: (context, value, child) {
//                 return Text(
//                   'Grace: $value s',
//                   style: const TextStyle(color: Colors.white),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



//******SOLUTION WITH PACKAGE*******//


import 'dart:async';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';

class InactivityListener extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;
  final Duration gracePeriodDuration;
  final ValueNotifier<int> inactivityTimerNotifier;
  final ValueNotifier<int> graceTimerNotifier;

  const InactivityListener({
    super.key,
    required this.child,
    required this.inactivityTimerNotifier,
    required this.graceTimerNotifier,
    this.timeoutDuration = const Duration(seconds: 10),
    this.gracePeriodDuration = const Duration(seconds: 10),
  });

  @override
  _InactivityListenerState createState() => _InactivityListenerState();
}

class _InactivityListenerState extends State<InactivityListener> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  Timer? _gracePeriodTimer;
  int _remainingInactivitySeconds = 0;
  int _remainingGraceSeconds = 0;
  bool _isGracePeriodActive = false;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocalNotifications();
    _startInactivityTimer();
    _initBackgroundFetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    _gracePeriodTimer?.cancel();
    super.dispose();
  }

  // Initialize Local Notifications
  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Start Inactivity Timer
  void _startInactivityTimer() {
    _cancelInactivityTimer();
    _remainingInactivitySeconds = widget.timeoutDuration.inSeconds;
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingInactivitySeconds > 0) {
        _remainingInactivitySeconds--;
        widget.inactivityTimerNotifier.value = _remainingInactivitySeconds;
      } else {
        timer.cancel();
        _handleInactivity();
      }
    });
  }

  // Handle Inactivity
  void _handleInactivity() {
    _startGracePeriod();
    _showLogoutWarning();
  }

  // Start Grace Period
  void _startGracePeriod() {
    setState(() {
      _isGracePeriodActive = true;
    });

    _remainingGraceSeconds = widget.gracePeriodDuration.inSeconds;
    widget.graceTimerNotifier.value = _remainingGraceSeconds;

    _gracePeriodTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingGraceSeconds > 0) {
        _remainingGraceSeconds--;
        widget.graceTimerNotifier.value = _remainingGraceSeconds;
      } else {
        timer.cancel();
        _performLogout();
      }
    });
  }

  // Perform Logout
  void _performLogout() {
    BlocProvider.of<AuthBloc>(context).add(AutoLogoutEvent());
  }

  // Reset Inactivity Timer
  void _resetInactivityTimer() {
    _startInactivityTimer();
    if (_isGracePeriodActive) {
      _cancelGracePeriodTimer();
    }
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
  }

  void _cancelGracePeriodTimer() {
    _gracePeriodTimer?.cancel();
    setState(() {
      _isGracePeriodActive = false;
    });
  }

  // Show Local Notification for Logout Warning
  void _showLogoutWarning() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'inactivity_channel',
      'Inactivity Warning',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Inactive for too long!',
      'You will be logged out soon.',
      platformChannelSpecifics,
    );
  }

  // Background Fetch Configuration
  void _initBackgroundFetch() {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
      ),
          (String taskId) async {
        _performLogout(); // Force logout during background fetch
        BackgroundFetch.finish(taskId);
      },
    );
  }

  // Listen to App Lifecycle Changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetInactivityTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _initBackgroundFetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      child: widget.child,
    );
  }
}

class TimerDisplay extends StatelessWidget {
  final ValueNotifier<int> inactivityTimerNotifier;
  final ValueNotifier<int> graceTimerNotifier;

  const TimerDisplay({
    super.key,
    required this.inactivityTimerNotifier,
    required this.graceTimerNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 60,
      padding: const EdgeInsets.all(1.0),
      child: Card(

        color:Colors.blueGrey.shade900,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: inactivityTimerNotifier,
              builder: (context, value, child) {
                return Text(
                  'Inactivity: $value s',
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: graceTimerNotifier,
              builder: (context, value, child) {
                return Text(
                  'Grace: $value s',
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



