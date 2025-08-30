import 'package:flutter/material.dart';
import 'package:flutter_ml/app_colors.dart';
import 'package:flutter_ml/medication_reminder.dart';
import 'package:flutter_ml/settings.dart';
import 'package:flutter_ml/Dl Model.dart';
import 'package:flutter_ml/chat_bot.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MedicationReminder(),
    MlModel(),
    BotScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = [
    'Medication Reminder',
    'Deep Learning Model',
    'Gemini Chatbot',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = AppColors.secondary;

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            )
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            selectedItemColor: activeColor,
            unselectedItemColor: inactiveColor,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 13,
            unselectedFontSize: 12,
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services),
                label: 'Medication',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'DL Model',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
