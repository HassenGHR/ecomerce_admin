import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:admin/blocs/auth/auth_bloc.dart';
import 'package:admin/blocs/auth/auth_event.dart';
import 'package:admin/blocs/auth/auth_state.dart';
import 'package:admin/repositories/local_auth_repository.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSnackBarShown = false; // Flag to track SnackBar display

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocProvider(
        create: (_) =>
            LoginBloc(authRepository: context.read<LocalAuthRepository>()),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess && !_isSnackBarShown) {
              _isSnackBarShown = true; // Set flag to true
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: theme.textTheme.displayLarge?.color,
                      fontSize: 14.sp, // Responsive font size
                    ),
                  ),
                  backgroundColor: Colors.green.shade400,
                ),
              );
              // Navigate to home screen
              Navigator.pushNamed(context, '/home');
            }
            if (state is LoginError && !_isSnackBarShown) {
              _isSnackBarShown = true; // Set flag to true
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: TextStyle(fontSize: 14.sp), // Responsive font size
                  ),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }

            // Reset the flag when the state changes
            if (state is! LoginSuccess && state is! LoginError) {
              _isSnackBarShown = false;
            }
          },
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ]
                      : [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w), // Responsive padding
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Animated Logo/Title
                            TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 800),
                              tween: Tween(begin: 0, end: 1),
                              builder: (context, opacity, child) {
                                return Opacity(
                                  opacity: opacity,
                                  child: Transform.translate(
                                    offset: Offset(0, 50 * (1 - opacity)),
                                    child: Text(
                                      'Welcome Back',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.displayMedium
                                          ?.copyWith(
                                        color: theme
                                            .textTheme.displayMedium?.color,
                                        letterSpacing: 1.2,
                                        fontSize: 28.sp, // Responsive font size
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 40.h), // Responsive spacing

                            // Name Input
                            _buildTextField(
                              controller: _nameController,
                              labelText: 'Full Name',
                              icon: Icons.person_outline,
                              theme: theme,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h), // Responsive spacing

                            // Phone Input
                            _buildTextField(
                              controller: _phoneController,
                              labelText: 'Phone Number',
                              icon: Icons.phone_outlined,
                              theme: theme,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                // Add more sophisticated phone validation if needed
                                return null;
                              },
                            ),
                            SizedBox(height: 32.h), // Responsive spacing

                            // Login Button
                            if (state is LoginLoading)
                              Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<LoginBloc>().add(
                                              LoginSubmitted(
                                                _nameController.text,
                                                _phoneController.text,
                                              ),
                                            );
                                      }
                                    },
                                    style: theme.elevatedButtonTheme.style,
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18.sp, // Responsive font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h), // Responsive spacing

                                  // Google Sign In Button
                                  OutlinedButton(
                                    onPressed: () async {
                                      // Trigger the Google login event
                                    },
                                    style: theme.outlinedButtonTheme.style,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: theme.iconTheme.color,
                                          size: 20.sp, // Responsive icon size
                                        ),
                                        SizedBox(
                                            width: 12.w), // Responsive spacing
                                        Text('Sign in with Google',
                                            style: theme.textTheme.titleMedium),
                                      ],
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
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom TextField with enhanced styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: theme.inputDecorationTheme.counterStyle?.copyWith(
        fontSize: 16.sp, // Responsive font size
      ),
      decoration: InputDecoration(
        fillColor: theme.inputDecorationTheme.fillColor,
        prefixIcon: Icon(
          icon,
          color: theme.iconTheme.color,
          size: 20.sp, // Responsive icon size
        ),
        labelText: labelText,
        labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
          fontSize: 16.sp, // Responsive font size
        ),
        floatingLabelStyle: theme.inputDecorationTheme.floatingLabelStyle,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r), // Responsive radius
          borderSide: BorderSide(
            color: theme.inputDecorationTheme.border!.borderSide.color,
            width: 1.5.w, // Responsive border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r), // Responsive radius
          borderSide: BorderSide(
            color: theme.inputDecorationTheme.outlineBorder?.color ??
                theme.colorScheme.primary,
            width: 2.w, // Responsive border width
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r), // Responsive radius
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5.w, // Responsive border width
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r), // Responsive radius
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2.w, // Responsive border width
          ),
        ),
      ),
    );
  }
}
