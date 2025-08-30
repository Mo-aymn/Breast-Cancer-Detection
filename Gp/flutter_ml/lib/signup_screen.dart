import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ml/app_colors.dart';
import 'package:flutter_ml/routes/app_routes_name.dart';
import 'package:flutter_ml/widgets/custom_button.dart';
import 'package:flutter_ml/widgets/text_field_widget.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideInLeft(
                      duration: Duration(seconds: 1),
                      child: Image.asset(
                        "assets/medical-team.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    SlideInRight(
                      duration: Duration(seconds: 1),
                      child: Text(
                        "Health Care",
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 26),
                      ),
                    )
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                textFieldWidget(
                  isPassword: false,
                  hintText: "Name",
                  prefixIcon: "assets/icons/person.png",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                textFieldWidget(
                  isPassword: false,
                  hintText: "Email",
                  prefixIcon: "assets/icons/email.png",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                textFieldWidget(
                  isPassword: true,
                  hintText: "password",
                  prefixIcon: "assets/icons/lock.png",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                textFieldWidget(
                  isPassword: true,
                  hintText: "Re-password",
                  prefixIcon: "assets/icons/lock.png",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                CustomButton(
                  text: "SignUp",
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, AppRoutesName.login);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, AppRoutesName.login);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
