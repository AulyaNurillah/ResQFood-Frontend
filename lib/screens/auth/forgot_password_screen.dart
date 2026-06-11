import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen
    extends StatefulWidget {

  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen>
      createState() =>
          _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final emailController =
      TextEditingController();

  final formKey =
      GlobalKey<FormState>();

  final authService =
      AuthService();

  bool isLoading = false;

  Future<void> sendResetLink()
  async {

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      await authService
          .forgotPassword(
        emailController.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
          title:
              const Text(
            "Email Sent",
          ),
          content:
              const Text(
            "Please check your email to reset your password.",
          ),
          actions: [

            TextButton(
              onPressed: () {

                Navigator.pop(
                  context,
                );

                Navigator.pop(
                  context,
                );

              },
              child:
                  const Text(
                "OK",
              ),
            ),

          ],
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            e.toString(),
          ),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            colors: [
              AppColors.background,
              AppColors.accent,
            ],
            begin:
                Alignment.topLeft,
            end:
                Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),

            child: Form(
              key: formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    padding:
                        EdgeInsets.zero,

                    alignment:
                        Alignment.centerLeft,

                    icon:
                        const Icon(
                      Icons.arrow_back_ios,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    "Enter your account email and we'll send you a password reset link.",
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  const Text(
                    "Email",
                    style: TextStyle(
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  TextFormField(
                    controller:
                        emailController,

                    validator:
                        (value) {

                      if (value ==
                              null ||
                          value
                              .isEmpty) {
                        return "Email wajib diisi";
                      }

                      return null;
                    },

                    decoration:
                        InputDecoration(
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width:
                        double.infinity,

                    height: 55,

                    child:
                        ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : sendResetLink,

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            AppColors.secondary,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),

                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                )
                              : const Text(
                                  "Send Reset Link",
                                  style:
                                      TextStyle(
                                    color:
                                        AppColors.cream,
                                    fontSize:
                                        18,
                                  ),
                                ),
                    ),
                  ),

                  const Spacer(),

                  const Center(
                    child: Text(
                      "ResQFood Password Recovery",
                      style: TextStyle(
                        color:
                            AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}