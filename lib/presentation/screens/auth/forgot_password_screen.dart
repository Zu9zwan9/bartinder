import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Forgot password screen following Apple HIG guidelines
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
            AuthPasswordResetRequested(
              email: _emailController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Reset Password'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => context.go('/auth/signin'),
        ),
        border: null,
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
                  const Icon(
                    CupertinoIcons.lock_rotation,
                    size: 80,
                    color: CupertinoColors.systemBlue,
                  ),

                  const SizedBox(height: 24),

                  // Header
                  const Text(
                    'Reset Your Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Enter your email address and we\'ll send you instructions to reset your password.',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

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
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          validator: _validateEmail,
                          onFieldSubmitted: (_) => _resetPassword(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Reset Password Button
                  CupertinoButton.filled(
                    onPressed: _resetPassword,
                    child: const Text(
                      'Send Reset Instructions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Additional Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.resolveFrom(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.info_circle,
                              size: 16,
                              color: CupertinoColors.secondaryLabel,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'What happens next?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Check your email inbox\n2. Click the reset link in the email\n3. Create a new password\n4. Sign in with your new password',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel,
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
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.label,
                        ),
                        children: [
                          TextSpan(text: 'Remember your password? '),
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
