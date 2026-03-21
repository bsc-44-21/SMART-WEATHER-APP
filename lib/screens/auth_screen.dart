import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'sign_up_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
    final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                            FarmingCard(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: Column(
                  children: [
                    const AppLogo(size: 80),
                    const SizedBox(height: 24),
                    Text('WeatherSmart', style: Theme.of(context).textTheme.displayLarge),
                    Text('Intelligent Farming Assistant', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 48),
                    CustomTextField(
                      label: 'EMAIL',
                      hint: 'example@gmail.com',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'PASSWORD',
                      hint: '••••••••',
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      isPassword: true,
                      onToggleVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                                        Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return ElevatedButton(