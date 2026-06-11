import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';

import '../buyer/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      await authService.login(
        email:
            emailController.text.trim(),
        password:
            passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => const HomeScreen(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
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
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(
          gradient: LinearGradient(
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
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 80,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    "Fill the form to sign in into account!",
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  const Text(
                    "Email",
                    style: TextStyle(
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextFormField(
                    controller:
                        emailController,

                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {
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
                    height: 20,
                  ),

                  const Text(
                    "Password",
                    style: TextStyle(
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextFormField(
                    controller:
                        passwordController,

                    obscureText:
                        obscurePassword,

                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {
                        return "Password wajib diisi";
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

                      suffixIcon:
                          IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {

                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
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
                              : login,

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .secondary,

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
                                  "Login",
                                  style:
                                      TextStyle(
                                    color:
                                        AppColors
                                            .cream,
                                    fontSize:
                                        20,
                                  ),
                                ),
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Text(
                        "Don't have an account?",
                      ),

                      TextButton(
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      const RegisterScreen(),
                            ),
                          );
                        },

                        child:
                            const Text(
                          "Sign Up here!",
                        ),
                      ),
                    ],
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