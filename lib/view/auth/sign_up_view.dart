import 'package:assignment6/constants/all_constants.dart';
import 'package:assignment6/controller/simple_ui_controller.dart';
import 'package:assignment6/providers/auth_provider.dart';
import 'package:assignment6/view/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  SimpleUIController simpleUIController = Get.put(SimpleUIController());
  late AuthProvider authProvider;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    authProvider = Get.find<AuthProvider>();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > Sizes.dimen_600) {
              return _buildLargeScreen(size, simpleUIController, theme);
            } else {
              return _buildSmallScreen(size, simpleUIController, theme);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLargeScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return Row(
      children: [
        Expanded(
            flex: 4,
            child: RotatedBox(
              quarterTurns: 0,
              child: Image.asset(
                'assets/images/auth.png',
                height: size.height * 0.6,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            )),
        SizedBox(
          width: size.width * 0.06,
        ),
        Expanded(
            flex: 5,
            child: _buildMainBody(
              size,
              simpleUIController,
              theme,
            ))
      ],
    );
  }

  Widget _buildSmallScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return Center(
      child: _buildMainBody(
        size,
        simpleUIController,
        theme,
      ),
    );
  }

  Widget _buildMainBody(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          size.width > 600 ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        size.width > 600
            ? Container()
            : Image.asset(
                'assets/images/wave.png',
                height: size.height * 0.2,
                width: size.width,
                fit: BoxFit.fill,
              ),
        SizedBox(
          height: size.height * 0.03,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text('Sign Up',
              style: TextStyle(
                fontSize: size.height * 0.060,
                fontWeight: FontWeight.bold,
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text('Create Account',
              style: TextStyle(
                fontSize: size.height * 0.030,
              )),
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// username
                TextFormField(
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),

                  controller: nameController,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    } else if (value.length < 4) {
                      return 'at least enter 4 characters';
                    } else if (value.length > 13) {
                      return 'maximum character is 13';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),

                /// Gmail
                TextFormField(
                  style: const TextStyle(color: Colors.black),
                  controller: emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_rounded),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gmail';
                    } else if (!value.endsWith('@gmail.com')) {
                      return 'please enter valid gmail';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),

                /// password
                Obx(
                  () => TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: passwordController,
                    obscureText: simpleUIController.isObscure.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_open),
                      suffixIcon: IconButton(
                        icon: Icon(
                          simpleUIController.isObscure.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          simpleUIController.isObscureActive();
                        },
                      ),
                      hintText: 'Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      } else if (value.length < 7) {
                        return 'at least enter 6 characters';
                      } else if (value.length > 13) {
                        return 'maximum character is 13';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(
                  height: size.height * 0.02,
                ),

                /// SignUp Button
                signUpButton(theme),
                SizedBox(
                  height: size.height * 0.03,
                ),

                /// Navigate To Login Screen
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (ctx) => const LoginView()));
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                    _formKey.currentState?.reset();

                    simpleUIController.isObscure.value = true;
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account?',
                      style: TextStyle(
                          fontSize: size.height * 0.022, color: Colors.black),
                      children: [
                        TextSpan(
                            text: " Login",
                            style: TextStyle(
                              fontSize: size.height * 0.022,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepPurpleAccent,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget signUpButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        onPressed: _signUp,
        child: const Text(
          'Sign up',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      bool success = await authProvider.createUser(
          emailController.text, passwordController.text, nameController.text);

      Navigator.of(context, rootNavigator: true)
          .pop(); // Close the loading indicator

      if (success) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(homeRoute, (route) => false);
      } else {
        // Handle signup failure (show error message, etc.)
      }
    }
  }
}
