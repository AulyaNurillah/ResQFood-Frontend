import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final fullNameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> register() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      await authService.register(
        fullName:
            fullNameController.text.trim(),

        phone:
            phoneController.text.trim(),

        email:
            emailController.text.trim(),

        password:
            passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Registrasi berhasil",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(e.toString()),
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
        width: double.infinity,
        height: double.infinity,

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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 20,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    "Sign Up",
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
                    "Fill the form to create your account!",
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  buildLabel(
                    "Full Name",
                  ),

                  buildField(
                    controller:
                        fullNameController,
                    validator:
                        (value) {

                      if (value == null ||
                          value.isEmpty) {
                        return "Nama wajib diisi";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  buildLabel(
                    "Email",
                  ),

                  buildField(
                    controller:
                        emailController,
                    validator:
                        (value) {

                      if (value == null ||
                          value.isEmpty) {
                        return "Email wajib diisi";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  buildLabel(
                    "Password",
                  ),

                  TextFormField(
                    controller:
                        passwordController,

                    obscureText:
                        obscurePassword,

                    validator:
                        (value) {

                      if (value == null ||
                          value.isEmpty) {
                        return "Password wajib diisi";
                      }

                      if (value.length < 8) {
                        return "Minimal 8 karakter";
                      }

                      return null;
                    },

                    decoration:
                        InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              AppColors.primary,
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              AppColors.secondary,
                          width: 2,
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
                    height: 14,
                  ),

                  buildLabel(
                    "Phone Number",
                  ),

                  buildField(
                    controller:
                        phoneController,

                    keyboardType:
                        TextInputType.phone,

                    validator:
                        (value) {

                      if (value == null ||
                          value.isEmpty) {
                        return "Nomor HP wajib diisi";
                      }

                      return null;
                    },
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
                              : register,

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
                                  "Sign Up",
                                  style:
                                      TextStyle(
                                    color:
                                        AppColors.cream,
                                    fontSize:
                                        20,
                                  ),
                                ),
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Text(
                        "Already have an account?",
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },

                        child:
                            const Text(
                          "Sign In here!",
                        ),
                      ),
                    ],
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

  Widget buildLabel(
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 6,
      ),

      child: Text(
        text,
        style: const TextStyle(
          color:
              AppColors.primary,
          fontSize: 15,
          fontWeight:
              FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController
        controller,

    required String? Function(
      String?,
    ) validator,

    TextInputType keyboardType =
        TextInputType.text,
  }) {

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.primary,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.secondary,
            width: 2,
          ),
        ),
      ),
    );
  }
}