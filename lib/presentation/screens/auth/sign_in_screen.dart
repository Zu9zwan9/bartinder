import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Sign in screen following Apple HIG guidelines
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sign In'),
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
                  const Icon(
                    CupertinoIcons.heart_fill,
                    size: 80,
                    color: CupertinoColors.systemPink,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Beer Tinder',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find your perfect bar match',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Email Field
                  CupertinoFormSection.insetGrouped(
                    children: [
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
                          textInputAction: TextInputAction.done,
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
                          onFieldSubmitted: (_) => _signIn(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign In Button
                  CupertinoButton.filled(
                    onPressed: _signIn,
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Forgot Password Button
                  CupertinoButton(
                    onPressed: () => context.go('/auth/forgot-password'),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 16,
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
                          color: CupertinoColors.separator.resolveFrom(context),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: CupertinoColors.separator.resolveFrom(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sign Up Button
                  CupertinoButton(
                    onPressed: () => context.go('/auth/signup'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.label,
                        ),
                        children: [
                          TextSpan(text: 'Don\'t have an account? '),
                          TextSpan(
                            text: 'Sign Up',
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
