import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ml/app_colors.dart';

class textFieldWidget extends StatefulWidget {
  final String hintText;
  final String prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const textFieldWidget(
      {super.key,
      required this.hintText,
      required this.prefixIcon,
      required this.isPassword,
      this.controller,
      this.validator});

  @override
  State<textFieldWidget> createState() => _textFieldWidgetState();
}

class _textFieldWidgetState extends State<textFieldWidget> {
  bool obscureText = false;
  @override
  void initState() {
    obscureText = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      controller: widget.controller,
      obscureText: obscureText ? true : false,
      style: TextStyle(
          color: AppColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
          hintStyle: TextStyle(color: AppColors.secondary),
          filled: true,
          fillColor: AppColors.third,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(360),
              borderSide: BorderSide(color: AppColors.secondary, width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(360),
              borderSide: BorderSide(color: AppColors.primary, width: 2)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(360),
              borderSide: BorderSide(color: AppColors.secondary, width: 2)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(360),
              borderSide: BorderSide(color: AppColors.secondary, width: 2)),
          hintText: widget.hintText,
          prefixIcon: ImageIcon(
            AssetImage(widget.prefixIcon),
            color: AppColors.secondary,
          ),
          suffixIcon: widget.isPassword
              ? InkWell(
                  child: Icon(
                    obscureText
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye,
                    color: AppColors.secondary,
                  ),
                  onTap: () {
                    obscureText = !obscureText;
                    setState(() {});
                  },
                )
              : null),
    );
  }
}
