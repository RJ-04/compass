import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _hasPermission = false;
  double turns = 0;
  double prevValue = 0;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Builder(
          builder: (context) {
            if (_hasPermission) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

// compass

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error reading Heading ${snapshot.error}");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.cyan),
            ),
          );
        } else {
          double? direction = snapshot.data!.heading;

          direction = direction! < 0 ? (360 + direction) : direction;
          double diff = direction - prevValue;
          if (diff.abs() > 180) {
            if (prevValue > direction) {
              diff = 360 - (direction - prevValue).abs();
            } else {
              diff = 360 - (prevValue - direction).abs();
              diff = diff * -1;
            }
          }
          turns += (diff / 360);
          prevValue = direction;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedRotation(
                  alignment: Alignment.center,
                  turns: turns * -1,
                  duration: const Duration(milliseconds: 550),
                  child: Image.asset(
                    'assests/_972d46da-f6e1-4f06-ac76-40e6d28edfe4.jpeg',
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

// permission sheet

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
        child: const Text("Request Permission"),
      ),
    );
  }
}
