import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ml/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class MedicationReminder extends StatefulWidget {
  @override
  _MedicationReminderState createState() => _MedicationReminderState();
}

class _MedicationReminderState extends State<MedicationReminder> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _medicationNameController =
      TextEditingController();
  DateTime? _selectedTime;
  List<Map<String, dynamic>> _medications = [];
  String _repeatOption = 'Daily'; // Default repeat option

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadMedications();
  }

  void _initializeNotifications() {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medicationsString = prefs.getString('medications');
    if (medicationsString != null) {
      setState(() {
        _medications =
            List<Map<String, dynamic>>.from(json.decode(medicationsString));
      });
    }
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medications', json.encode(_medications));
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _setReminder() async {
    if (_selectedTime == null || _medicationNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter medication name and select time')),
      );
      return;
    }

    setState(() {
      _medications.add({
        'name': _medicationNameController.text,
        'time': DateFormat('hh:mm a').format(_selectedTime!),
        'repeat': _repeatOption,
      });
    });

    await _saveMedications();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Reminder set for ${_medicationNameController.text} at ${DateFormat('hh:mm a').format(_selectedTime!)}')),
    );

    _scheduleNotification(_medications.length - 1);
  }

  Future<void> _scheduleNotification(int id) async {
    if (_selectedTime == null) return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(_selectedTime!, tz.local);

    if (scheduledTime.isBefore(now)) {
      print("⚠️ لا يمكن ضبط إشعار في الماضي. تأكد من اختيار وقت مستقبلي.");
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_reminder',
      'Medicine Reminder',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Medicine Reminder',
      'Time to take: ${_medications[id]["name"]}',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _repeatOption == 'Daily'
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _deleteMedication(int index) async {
    setState(() {
      _medications.removeAt(index);
    });

    await _saveMedications();
  }

  void _editMedication(int index) async {
    final medication = _medications[index];
    _medicationNameController.text = medication['name'];
    _selectedTime = DateFormat('hh:mm a').parse(medication['time']);
    _repeatOption = medication['repeat'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Medication"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _medicationNameController,
                decoration: InputDecoration(labelText: 'Medication Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text(_selectedTime == null
                    ? 'Select Time'
                    : 'Selected Time: ${DateFormat('hh:mm a').format(_selectedTime!)}'),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _repeatOption,
                items: ['Daily', 'Weekly'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _repeatOption = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _medications[index] = {
                    'name': _medicationNameController.text,
                    'time': DateFormat('hh:mm a').format(_selectedTime!),
                    'repeat': _repeatOption,
                  };
                });
                _saveMedications();
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDarkMode ? Colors.tealAccent : AppColors.primary;
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color cardColor = isDarkMode ? Colors.grey[900]! : AppColors.third;
    Color textColor = isDarkMode ? Colors.white : AppColors.secondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Medication Reminder',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22)),
        backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            children: [
              TextField(
                controller: _medicationNameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  labelStyle: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  prefixIcon: Icon(Icons.medical_services, color: textColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.secondary)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.secondary)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.secondary)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _selectTime(context),
                icon: Icon(Icons.access_time,color: Colors.white,),
                label: Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : 'Selected Time: ${DateFormat('hh:mm a').format(_selectedTime!)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    iconColor: AppColors.secondary,
                    iconSize: 25),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _repeatOption,
                items: ['Daily', 'Weekly'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _repeatOption = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _setReminder,
                icon: Icon(Icons.notifications_active,color: Colors.white,),
                label: Text('Set Reminder',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    iconColor: AppColors.secondary,
                    iconSize: 22),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _medications.isEmpty
                    ? Center(
                        child: Text(
                        'No medications added yet.',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ))
                    : ListView.separated(
                        itemCount: _medications.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: textColor.withOpacity(0.5)),
                        itemBuilder: (context, index) {
                          final medication = _medications[index];
                          return Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(medication['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                              subtitle: Text(
                                  'Time: ${medication['time']}\nRepeat: ${medication['repeat']}',
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.7))),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editMedication(index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteMedication(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
