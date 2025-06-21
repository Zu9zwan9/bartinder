import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/location_service.dart';
import '../../data/repositories/user_repository_impl.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignedUp;
  const SignUpScreen({super.key, required this.onSignedUp});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;
  final _locationService = LocationService();
  final _userRepo = UserRepositoryImpl();

  Future<void> _saveUser() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final email = _emailController.text.trim();
    await prefs.setString('user_name', name);
    await prefs.setString('user_age', age);
    await prefs.setString('user_email', email);
    final userId = email;
    final position = await _locationService.getCurrentLocation();
    try {
      await _userRepo.saveUserWithLocation(
        id: userId,
        name: name,
        age: int.tryParse(age) ?? 0,
        email: email,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
      );
    } catch (e) {
      // Можно добавить обработку ошибок
    }
    setState(() => _loading = false);
    widget.onSignedUp();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Create Account'),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Name',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: _ageController,
                    placeholder: 'Age',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),
                  CupertinoButton.filled(
                    child: _loading ? const CupertinoActivityIndicator() : const Text('Create Account'),
                    onPressed: _loading
                        ? null
                        : () {
                            if (_nameController.text.trim().isEmpty ||
                                _ageController.text.trim().isEmpty ||
                                _emailController.text.trim().isEmpty) {
                              showCupertinoDialog(
                                context: context,
                                builder: (ctx) => CupertinoAlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Please fill all fields.'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.of(ctx).pop(),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            _saveUser();
                          },
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
