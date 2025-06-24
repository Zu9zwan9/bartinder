import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

/// Wrapper that handles authentication state and navigation
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle navigation based on auth state
        if (state is AuthUnauthenticated) {
          context.go('/auth/signin');
        } else if (state is AuthEmailVerificationRequired) {
          _showEmailVerificationDialog(context, state.email);
        } else if (state is AuthPasswordResetSent) {
          _showPasswordResetSentDialog(context, state.email);
        } else if (state is AuthFailure) {
          _showErrorDialog(context, state.error);
        }
      },
      builder: (context, state) {
        // Show loading screen during initial auth check
        if (state is AuthInitial || state is AuthLoading) {
          return const _LoadingScreen();
        }

        // Show loading overlay during auth operations
        if (state is AuthInProgress) {
          return Stack(
            children: [
              child,
              _LoadingOverlay(message: state.operation),
            ],
          );
        }

        // Show main content if authenticated
        if (state is AuthAuthenticated) {
          return child;
        }

        // For any other state, show loading (navigation will handle redirect)
        return const _LoadingScreen();
      },
    );
  }

  void _showEmailVerificationDialog(BuildContext context, String email) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Verify Your Email'),
        content: Text(
          'We\'ve sent a verification email to $email. Please check your inbox and click the verification link to complete your registration.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/auth/signin');
            },
          ),
        ],
      ),
    );
  }

  void _showPasswordResetSentDialog(BuildContext context, String email) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Password Reset Sent'),
        content: Text(
          'We\'ve sent password reset instructions to $email. Please check your inbox and follow the instructions to reset your password.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/auth/signin');
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Loading screen shown during initial auth check
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              radius: 20,
            ),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading overlay shown during auth operations
class _LoadingOverlay extends StatelessWidget {
  final String message;

  const _LoadingOverlay({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.black.withAlpha(77),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(
                radius: 16,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
