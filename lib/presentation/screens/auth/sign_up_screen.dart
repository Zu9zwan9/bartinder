import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../theme/theme.dart';

/// Sign up screen following Apple HIG guidelines with dark mode support
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

  // for password validation UI
  bool _has8Chars = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordRequirements);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordRequirements);
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

  void _updatePasswordRequirements() {
    final password = _passwordController.text;
    setState(() {
      _has8Chars = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
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
      backgroundColor: AppTheme.mineShaft,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Sign Up',
          style: AppTheme.navTitle.copyWith(color: AppTheme.textColor(context)),
        ),
        backgroundColor: AppTheme.isDarkMode(context)
            ? AppTheme.darkCardColor
            : Colors.white,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: AppTheme.systemBlue(context),
          onPressed: () => context.go('/auth/signin'),
        ),
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
                  Image.asset(
                    'assets/images/icon.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sip. Swipe. Repeat.',
                    style: AppTheme.subhead.copyWith(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Form fields
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Name field
                        _buildFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          placeholder: 'Full Name',
                          icon: CupertinoIcons.person,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) =>
                              _emailFocusNode.requestFocus(),
                        ),

                        _buildDivider(),

                        // Email field
                        _buildFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          placeholder: 'Email',
                          icon: CupertinoIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          onFieldSubmitted: (_) => _ageFocusNode.requestFocus(),
                        ),

                        _buildDivider(),

                        // Age field
                        _buildFormField(
                          controller: _ageController,
                          focusNode: _ageFocusNode,
                          placeholder: 'Age',
                          icon: CupertinoIcons.calendar,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              _passwordFocusNode.requestFocus(),
                        ),

                        _buildDivider(),

                        // Password field
                        _buildPasswordFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          placeholder: 'Password',
                          obscureText: _obscurePassword,
                          onToggleObscureText: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              _confirmPasswordFocusNode.requestFocus(),
                        ),

                        _buildDivider(),

                        // Confirm Password field
                        _buildPasswordFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          placeholder: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          onToggleObscureText: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _signUp(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Requirements
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode(context)
                          ? AppTheme.darkSurfaceColor
                          : AppTheme.systemGray6(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password must contain:',
                          style: AppTheme.footnote.copyWith(
                            color: AppTheme.secondaryTextColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordRequirement(
                          'At least 8 characters',
                          _has8Chars,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'An uppercase letter',
                          _hasUppercase,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'A lowercase letter',
                          _hasLowercase,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement('A number', _hasNumber),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Button
                  CupertinoButton(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _signUp,
                    child: Text(
                      'Create Account',
                      style: AppTheme.button.copyWith(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    style: AppTheme.caption1.copyWith(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Sign In Button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.go('/auth/signin'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.body.copyWith(
                          color: AppTheme.secondaryTextColor(context),
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
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

  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool autocorrect = true,
    void Function(String)? onFieldSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryTextColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              focusNode: focusNode,
              placeholder: placeholder,
              placeholderStyle: AppTheme.body.copyWith(
                color: AppTheme.secondaryTextColor(context),
              ),
              style: AppTheme.body.copyWith(color: AppTheme.textColor(context)),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              autocorrect: autocorrect,
              decoration: BoxDecoration(color: AppTheme.cardColor(context)),
              padding: EdgeInsets.zero,
              onSubmitted: onFieldSubmitted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    required bool obscureText,
    required VoidCallback onToggleObscureText,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            placeholder == 'Password'
                ? CupertinoIcons.lock
                : CupertinoIcons.lock_fill,
            color: AppTheme.secondaryTextColor(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              focusNode: focusNode,
              placeholder: placeholder,
              placeholderStyle: AppTheme.body.copyWith(
                color: AppTheme.secondaryTextColor(context),
              ),
              style: AppTheme.body.copyWith(color: AppTheme.textColor(context)),
              obscureText: obscureText,
              textInputAction: textInputAction,
              decoration: BoxDecoration(color: AppTheme.cardColor(context)),
              padding: EdgeInsets.zero,
              onSubmitted: onFieldSubmitted,
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(left: 12),
            onPressed: onToggleObscureText,
            child: Icon(
              obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: AppTheme.secondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppTheme.dividerColor(context),
    );
  }

  Widget _buildPasswordRequirement(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
          color: met
              ? AppTheme.systemGreen(context)
              : AppTheme.secondaryTextColor(context),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.secondaryTextColor(context),
            ),
          ),
        ),
      ],
    );
  }
}
