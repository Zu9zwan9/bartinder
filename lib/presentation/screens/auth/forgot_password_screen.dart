import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../theme/theme.dart';

/// Forgot password screen following Apple HIG guidelines with dark mode support
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthPasswordResetRequested(email: _emailController.text.trim()),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.mineShaft,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Reset Password',
          style: AppTheme.navTitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.mineShaft,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: AppTheme.systemBlue(context),
          onPressed: () => context.go('/auth/signin'),
        ),
      ),
      child: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetSent) {
              // The auth wrapper will handle showing the success dialog
              // and navigating back to sign in
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

                  // Icon
                  Icon(
                    CupertinoIcons.lock_rotation,
                    size: 80,
                    color: AppTheme.systemBlue(context),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'Reset Your Password',
                    style: AppTheme.title1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Enter your email address and we\'ll send you instructions to reset your password.',
                    style: AppTheme.subhead.copyWith(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                            style: AppTheme.body.copyWith(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            decoration: const BoxDecoration(
                              color: AppTheme.darkCardColor,
                            ),
                            padding: EdgeInsets.zero,
                            onSubmitted: (_) => _resetPassword(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reset Password Button
                  CupertinoButton(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _resetPassword,
                    child: Text(
                      'Send Reset Instructions',
                      style: AppTheme.button.copyWith(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Additional Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.info_circle,
                              size: 16,
                              color: AppTheme.secondaryTextColor(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'What happens next?',
                              style: AppTheme.footnote.copyWith(
                                color: AppTheme.secondaryTextColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Check your email inbox\n2. Click the reset link in the email\n3. Create a new password\n4. Sign in with your new password',
                          style: AppTheme.caption1.copyWith(
                            color: AppTheme.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Back to Sign In Button
                  CupertinoButton(
                    onPressed: () => context.go('/auth/signin'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.body.copyWith(color: Colors.white),
                        children: [
                          const TextSpan(text: 'Remember your password? '),
                          TextSpan(
                            text: 'Sign In',
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
