import 'package:flutter/material.dart';
import 'package:xorr/shared/consts/app_consts.dart';
import 'package:xorr/shared/theme/app_fonts.dart';
import 'package:xorr/shared/ui/buttons.dart';
import 'package:xorr/shared/ui/text_fields.dart';

class LoginView extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          AppConsts.appName,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontFamily: AppFonts.sourceSerif4,
                          ),
                        ),

                        Text(
                          'Your documents. Your ideas. One place.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sigin to access your workspace',
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 20),
                        appTextField(
                          controller: _emailController,
                          hintText: "user@example.com",
                          onPressed: () {},
                        ),
                        const SizedBox(height: 20),
                        appTextField(
                          controller: _passwordController,
                          hintText: "password",
                          onPressed: () {},
                        ),
                        const SizedBox(height: 20),
                        appButton(
                          isLoading: true,
                          text: 'Continue',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Text("Don't have an account?"),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {},
                              child: Text(
                                'Signup',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
