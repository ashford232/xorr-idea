import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/auth/views/login_view.dart';
import 'package:xorr/features/auth/wrappers/auth_wrapper.dart';
import 'package:xorr/shared/consts/app_consts.dart';
import 'package:xorr/shared/consts/utils.dart';
import 'package:xorr/shared/extensions/app_router.dart';
import 'package:xorr/shared/theme/app_fonts.dart';
import 'package:xorr/shared/ui/buttons.dart';
import 'package:xorr/shared/ui/dialogs.dart';
import 'package:xorr/shared/ui/text_fields.dart';

class SignupView extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscuredText.dispose();
    _obscuredTextConfirm.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  final ValueNotifier<bool> _obscuredText = ValueNotifier(true);
  final ValueNotifier<bool> _obscuredTextConfirm = ValueNotifier(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400),
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
                                const SizedBox(height: 10),
                                Text(
                                  'Create an account',
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 10),
                                const SizedBox(height: 5),

                                appTextField(
                                  prefix: Icon(Icons.email_outlined),
                                  controller: _emailController,
                                  hintText: "Enter your email",
                                  onPressed: () {},
                                  validator: Utils.emailValidator,
                                ),
                                const SizedBox(height: 10),

                                const SizedBox(height: 5),
                                ValueListenableBuilder(
                                  valueListenable: _obscuredText,
                                  builder: (context, obscuredText, child) {
                                    return appTextField(
                                      prefix: Icon(Icons.lock_outline),
                                      controller: _passwordController,
                                      hintText: "Enter a password",
                                      onPressed: () {},
                                      obscureText: obscuredText,
                                      suffix: GestureDetector(
                                        onTap: () {
                                          _obscuredText.value =
                                              !_obscuredText.value;
                                        },
                                        child: Icon(
                                          obscuredText
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                      validator: Utils.passwordValidator,
                                    );
                                  },
                                ),

                                const SizedBox(height: 10),

                                ValueListenableBuilder(
                                  valueListenable: _obscuredTextConfirm,
                                  builder: (context, obscuredText, child) {
                                    return appTextField(
                                      prefix: Icon(Icons.lock_outline),
                                      controller: _confirmPasswordController,
                                      hintText: "Confirm your password",
                                      onPressed: () {},
                                      obscureText: obscuredText,
                                      suffix: GestureDetector(
                                        onTap: () {
                                          _obscuredTextConfirm.value =
                                              !_obscuredTextConfirm.value;
                                        },
                                        child: Icon(
                                          obscuredText
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                      validator: (string) {
                                        if (_passwordController.text.isEmpty) {
                                          return "";
                                        }
                                        if (_confirmPasswordController
                                            .text
                                            .isEmpty) {
                                          return "Confirm your password";
                                        }

                                        if (_passwordController.text !=
                                            _confirmPasswordController.text) {
                                          return "Passwords don't match.";
                                        }

                                        return null;
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                ValueListenableBuilder(
                                  valueListenable: _isLoading,
                                  builder: (context, isLoading, child) {
                                    return appButton(
                                      text: 'Create Account',
                                      onPressed: registerUser,
                                      isLoading: isLoading,
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,

                                      child: GestureDetector(
                                        onTap: () {
                                          if (AppRouter.canPop()) {
                                            AppRouter.back();
                                          } else {
                                            AppRouter.to(const LoginView());
                                          }
                                        },
                                        child: Text(
                                          'Sign in',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: .bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    Text("Instead?"),
                                  ],
                                ),

                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Text(
                  "${AppConsts.appVersionName}  |  ${AppConsts.company}  |  ${AppConsts.developer}  |  © 2026",
                ),
                Text("All rights reserved."),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    try {
      final isvalidated = formKey.currentState?.validate() ?? false;

      if (!isvalidated) {
        return;
      }
      final res = await DesktopDialogs.confirm(
        context,
        title: "Is this the correct email?",
        message: _emailController.text,
      );
      if (!res) {
        return;
      }
      _isLoading.value = true;
      final result = await ref
          .read(authRepositoryProvider)
          .signup(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (mounted) {
        if (result.user != null) {
          ref.invalidate(getUserProvider);
          AppRouter.to(AuthWrapper());
        } else {
          DesktopDialogs.error(
            context,
            message: result.message ?? "Something went wrong.",
          );
        }
      }
    } catch (err) {
      debugPrint(err.toString());
      if (mounted) {
        DesktopDialogs.error(context, message: err.toString());
      }
    } finally {
      _isLoading.value = false;
    }
  }
}
