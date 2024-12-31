import 'package:flutter/material.dart';
import 'dart:async';  // For Timer
import 'package:intl/intl.dart';  // For formatting the time
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';  // For setting screen orientation
import 'package:flutter_tts/flutter_tts.dart';  // For text-to-speech functionality
import 'package:battery_plus/battery_plus.dart';  // For battery percentage

// StateProvider to manage theme (light/dark mode)
final themeProvider = StateProvider<bool>((ref) => true); // false for light mode, true for dark mode
final clockFormatProvider = StateProvider<bool>((ref) => true); // true for 24-hour, false for 12-hour format

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  // Set the screen orientation to landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft
  ]).then((_) {
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
    bool is24HourFormat = ref.watch(clockFormatProvider);

    return MaterialApp(
      title: 'Digital Clock',
      theme: ThemeData(
        brightness: Brightness.light, // Light mode theme
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Choose a more modern font
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Dark mode theme
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Toggle between light and dark mode
      home: DigitalClock(is24HourFormat: is24HourFormat),
    );
  }
}

class DigitalClock extends ConsumerStatefulWidget {
  final bool is24HourFormat;

  const DigitalClock({super.key, required this.is24HourFormat});

  @override
  ConsumerState createState() => _DigitalClockState();
}

class _DigitalClockState extends ConsumerState<DigitalClock> {
  late Timer _timer;
  String _currentTime = "";
  String _currentDate = "";
  FlutterTts? flutterTts; // Change to nullable
  late Battery _battery;
  int? batteryLevel;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts(); // Initialize flutterTts here
    _battery = Battery();
    _currentDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()); // Initialize date on app start
    _currentTime = _getFormattedTime(); // Initialize time on app start
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime); // Update time every second

    _getBatteryLevel(); // Get the battery level when the app starts
  }

  // Method to update the current time
  void _updateTime(Timer? timer) {
    setState(() {
      _currentTime = _getFormattedTime(); // Get the current system time
      _currentDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
    });
  }

  // Method to get the formatted time based on 12-hour or 24-hour format
  String _getFormattedTime() {
    if (widget.is24HourFormat) {
      return DateFormat('HH:mm:ss').format(DateTime.now());  // 24-hour format
    } else {
      return DateFormat('hh:mm:ss a').format(DateTime.now());  // 12-hour format
    }
  }

  // Method to fetch battery level
  Future<void> _getBatteryLevel() async {
    batteryLevel = await _battery.batteryLevel;
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    flutterTts?.stop(); // Stop text-to-speech when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(themeProvider);
    bool is24HourFormat = ref.watch(clockFormatProvider);

    // Voice feedback for time
    flutterTts?.speak("Current time is $_currentTime"); // Safely call speak() only when flutterTts is initialized

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Set background color for the entire screen
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Digital Clock Text with a shadow effect
                AnimatedDefaultTextStyle(
                  style: TextStyle(
                    fontSize: 120, // Large font size for digital clock
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron', // Digital-style font
                    color: isDarkMode ? Colors.white : Colors.black, // Text color based on theme
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.blueAccent,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 300),
                  child: Text(_currentTime), // Display the current time
                ),
                SizedBox(height: 10),
                // Display Date below the clock
                Text(
                  _currentDate,
                  style: TextStyle(
                    fontSize: 30,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40), // Spacing between clock and toggle
        
                // Battery Percentage display
                Text(
                  "Battery: $batteryLevel%",
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 20),
        
                // Theme Toggle (Floating Action Button for a modern feel)
                FloatingActionButton(
                  onPressed: () {
                    ref.read(themeProvider.notifier).state = !isDarkMode;
                  },
                  child: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    size: 30,
                  ),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue[400],
                ),
                SizedBox(height: 20),
        
                // Clock Format Toggle (Switch between 12-hour and 24-hour format)
                SwitchListTile(
                  title: Text(
                    '24-hour format',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: is24HourFormat,
                  onChanged: (value) {
                    ref.read(clockFormatProvider.notifier).state = value;
                  },
                  secondary: Icon(
                    is24HourFormat ? Icons.access_time : Icons.access_alarm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
