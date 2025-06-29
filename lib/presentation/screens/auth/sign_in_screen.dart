import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../theme/theme.dart';

/// Sign in screen following Apple HIG guidelines with dark mode support
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.mineShaft,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Sign In',
          style: AppTheme.navTitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.mineShaft,
        border: null,
      ),
      child: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/');
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // App Logo/Title
                  Image.asset(
                    'assets/images/icon.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  Text(
                    'Sip. Swipe. Repeat.',
                    style: AppTheme.subhead.copyWith(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.mail,
                                color: AppTheme.secondaryTextColor(context),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  placeholder: 'Email',
                                  placeholderStyle: AppTheme.body.copyWith(
                                    color: AppTheme.secondaryTextColor(context),
                                  ),
                                  style: AppTheme.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.darkCardColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onSubmitted: (_) {
                                    _passwordFocusNode.requestFocus();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppTheme.dividerColor(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.lock,
                                color: AppTheme.secondaryTextColor(context),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  placeholder: 'Password',
                                  placeholderStyle: AppTheme.body.copyWith(
                                    color: AppTheme.secondaryTextColor(context),
                                  ),
                                  style: AppTheme.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.darkCardColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onSubmitted: (_) => _signIn(),
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  color: AppTheme.secondaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign In Button
                  CupertinoButton(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _signIn,
                    child: Text(
                      'Sign In',
                      style: AppTheme.button.copyWith(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Forgot Password Button
                  CupertinoButton(
                    onPressed: () => context.go('/auth/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: AppTheme.body.copyWith(
                        color: AppTheme.systemBlue(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.dividerColor(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: AppTheme.caption1.copyWith(
                            color: AppTheme.secondaryTextColor(context),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.dividerColor(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Apple Sign In Button
                  CupertinoButton(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthAppleSignInRequested());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.device_phone_portrait,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Continue with Apple',
                          style: AppTheme.button.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Google Sign In Button
                  CupertinoButton(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Continue with Google',
                          style: AppTheme.button.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign Up Button
                  CupertinoButton(
                    onPressed: () => context.go('/auth/signup'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.body.copyWith(color: Colors.white),
                        children: [
                          const TextSpan(text: 'Don\'t have an account? '),
                          TextSpan(
                            text: 'Sign Up',
                            style: AppTheme.body.copyWith(
                              color: AppTheme.systemBlue(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
