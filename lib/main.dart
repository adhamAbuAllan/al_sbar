import 'package:flutter/material.dart';
import 'dart:async';  // For Timer
import 'package:intl/intl.dart';  // For formatting the time
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';  // For setting screen orientation

// StateProvider to manage theme (light/dark mode)
final themeProvider = StateProvider<bool>((ref) => false); // false for light mode, true for dark mode

void main() {
  // Set the screen orientation to landscape
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme state from Riverpod
    bool isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Digital Clock',
      theme: ThemeData(
        brightness: Brightness.light,  // Light mode theme
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,  // Dark mode theme
        primarySwatch: Colors.blue,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,  // Toggle between light and dark mode
      home: DigitalClock(),
    );
  }
}

class DigitalClock extends StatefulWidget {
  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late Timer _timer;
  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());  // Initialize time on app start
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);  // Update time every second
  }

  // Method to update the current time
  void _updateTime(Timer? timer) {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());  // Get the current system time
    });
  }

  @override
  void dispose() {
    _timer.cancel();  // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Clock'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Digital Clock Text with dynamic color based on the theme mode
              Text(
                _currentTime,
                style: TextStyle(
                  fontSize: 48,  // You can increase/decrease the font size
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',  // Optional: Gives it a digital look
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white  // Dark mode: White color
                      : Colors.black, // Light mode: Black color
                ),
              ),
              SizedBox(width: 40), // Spacing between the clock and the toggle
              // Toggle Switch for Dark/Light mode using Riverpod
              Consumer(
                builder: (context, ref, child) {
                  bool isDarkMode = ref.watch(themeProvider);

                  return SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).state = value;
                    },
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
