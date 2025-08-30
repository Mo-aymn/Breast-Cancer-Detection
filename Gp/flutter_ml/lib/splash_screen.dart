import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ml/app_colors.dart';
import 'package:flutter_ml/routes/app_routes_name.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          ZoomIn(
            duration: Duration(seconds: 1),
            onFinish: (direction) {
              Future.delayed(
                Duration(seconds: 2),
                () {
                  Navigator.pushReplacementNamed(context, AppRoutesName.login);
                },
              );
            },
            child: Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Image.asset("assets/medical-team.png")),
            ),
          ),
          ZoomIn(
            duration: Duration(seconds: 1),
            child: Text(
              "Health Care",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Spacer(),
          FadeInUp(
            duration: Duration(seconds: 3),
            child: Text(
              "Supervised by DR Aml Abotabel",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
