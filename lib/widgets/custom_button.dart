import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton
    extends StatelessWidget {

  final String title;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.secondary,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
        ),

        child: Text(
          title,

          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}