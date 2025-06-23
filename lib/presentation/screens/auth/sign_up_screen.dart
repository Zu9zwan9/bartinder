import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Sign up screen following Apple HIG guidelines
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
              age: int.parse(_ageController.text),
            ),
          );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    if (age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sign Up'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => context.go('/auth/signin'),
        ),
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
                  const SizedBox(height: 20),

                  // Header
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join Beer Tinder to find your perfect bar match',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Form Fields
                  CupertinoFormSection.insetGrouped(
                    children: [
                      CupertinoFormRow(
                        prefix: const Icon(
                          CupertinoIcons.person,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        child: CupertinoTextFormFieldRow(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          placeholder: 'Full Name',
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: _validateName,
                          onFieldSubmitted: (_) {
                            _emailFocusNode.requestFocus();
                          },
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: const Icon(
                          CupertinoIcons.mail,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        child: CupertinoTextFormFieldRow(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          placeholder: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          validator: _validateEmail,
                          onFieldSubmitted: (_) {
                            _ageFocusNode.requestFocus();
                          },
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: const Icon(
                          CupertinoIcons.calendar,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        child: CupertinoTextFormFieldRow(
                          controller: _ageController,
                          focusNode: _ageFocusNode,
                          placeholder: 'Age',
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: _validateAge,
                          onFieldSubmitted: (_) {
                            _passwordFocusNode.requestFocus();
                          },
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: const Icon(
                          CupertinoIcons.lock,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        child: CupertinoTextFormFieldRow(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          placeholder: 'Password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                          prefix: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            }, minimumSize: Size(0, 0),
                            child: Icon(
                              _obscurePassword
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          onFieldSubmitted: (_) {
                            _confirmPasswordFocusNode.requestFocus();
                          },
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: const Icon(
                          CupertinoIcons.lock_fill,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        child: CupertinoTextFormFieldRow(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          placeholder: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmPassword,
                          prefix: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            }, minimumSize: Size(0, 0),
                            child: Icon(
                              _obscureConfirmPassword
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          onFieldSubmitted: (_) => _signUp(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Password Requirements
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.resolveFrom(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• At least 8 characters\n• Contains uppercase letter\n• Contains lowercase letter\n• Contains number',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Button
                  CupertinoButton.filled(
                    onPressed: _signUp,
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  const Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Sign In Button
                  CupertinoButton(
                    onPressed: () => context.go('/auth/signin'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.label,
                        ),
                        children: [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: CupertinoColors.activeBlue,
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
