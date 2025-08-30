import 'package:flutter/material.dart';
import 'package:flutter_ml/app_colors.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart'; // استيراد ThemeProvider

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _fontSize = 16.0; // حجم الخط الافتراضي

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? Colors.black
          : Colors.white, // خلفية مريحة للعين
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 إعداد الوضع الليلي
            Card(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                secondary: Icon(Icons.dark_mode, color: Colors.white),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),

            SizedBox(height: 20),

            // 🔹 إعداد حجم الخط
            Card(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.text_fields, color: Colors.white),
                    title: Text(
                      'Font Size',
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Adjust the text size',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    label: _fontSize.toStringAsFixed(1),
                    activeColor: themeProvider.isDarkMode
                        ? Colors.orange
                        : AppColors.secondary,
                    inactiveColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 🔹 إعدادات أخرى (يمكنك إضافة المزيد هنا)
            Card(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Colors.white),
                title: Text(
                  'About App',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('About App'),
                      content: Text(
                          'This is a medical reminder app developed using Flutter.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
