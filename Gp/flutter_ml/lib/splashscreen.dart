import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // تأكد من استيراد هذه المكتبة
import 'package:lottie/lottie.dart';
import 'home_screen.dart'; // استيراد الشاشة الرئيسية

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _time;

  void start() {
    _time = Timer(Duration(seconds: 5), call); // تقليل المدة إلى 3 ثوانٍ
  }

  void call() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()), // الانتقال إلى HomeScreen
    );
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  void dispose() {
    _time?.cancel(); // إلغاء Timer إذا كان غير null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff55598d),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle( // استخدام SystemUiOverlayStyle هنا
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Color(0xff55598d),
        elevation: 0,
      ),
      body: Center(
        child: Lottie.network(
          'https://assets3.lottiefiles.com/packages/lf20_kbfzivr8.json',
        ),
      ),
    );
  }
}