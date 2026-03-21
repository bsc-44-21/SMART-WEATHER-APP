import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                            FarmingCard(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: Column(
                  children: [
                    const AppLogo(size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    Text(
                      'Join WeatherSmart today',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 40),
                                        CustomTextField(
                      label: 'FULL NAME',
                      hint: 'John Doe',
                      controller: _fullNameController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'EMAIL',
                      hint: 'example@gmail.com',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'PASSWORD',
                      hint: '••••••••',
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      isPassword: true,
                      onToggleVisibility: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'CONFIRM PASSWORD',
                      hint: '••••••••',
                      controller: _confirmPasswordController,
                      obscureText: !_isPasswordVisible,
                      isPassword: true,
                      onToggleVisibility: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    const SizedBox(height: 24),
                                        Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (val) {
                            setState(() {
                              _agreedToTerms = val ?? false;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms & Conditions and Privacy Policy',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                                        Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return ElevatedButton(
  
}
