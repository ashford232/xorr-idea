import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/auth/views/signup_view.dart';
import 'package:xorr/features/auth/wrappers/auth_wrapper.dart';
import 'package:xorr/features/home/widgets/sidebar.dart';
import 'package:xorr/shared/consts/app_consts.dart';
import 'package:xorr/shared/consts/utils.dart';
import 'package:xorr/shared/extensions/app_router.dart';
import 'package:xorr/shared/theme/app_fonts.dart';
import 'package:xorr/shared/ui/buttons.dart';
import 'package:xorr/shared/ui/dialogs.dart';
import 'package:xorr/shared/ui/text_fields.dart';

class LoginView extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscuredText.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  final ValueNotifier<bool> _obscuredText = ValueNotifier(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Form(
            key: _formkey,
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
                                SidebarCard(
                                  text: 'Continue without account',
                                  icon: Icons.arrow_forward,
                                  toggled: false,
                                  onPressed: () {
                                    AppRouter.to(AuthWrapper());
                                  },
                                ),
                                const SizedBox(height: 20),
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
                                  'Sign in to access your workspace',
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 10),

                                appTextField(
                                  prefix: Icon(Icons.email_outlined),
                                  controller: _emailController,
                                  hintText: "Enter your email",
                                  autofillHints: {"email"},
                                  textInputType: .emailAddress,

                                  validator: Utils.emailValidator,
                                ),
                                const SizedBox(height: 10),

                                ValueListenableBuilder(
                                  valueListenable: _obscuredText,
                                  builder: (context, obscuredText, child) {
                                    return appTextField(
                                      validator: (value) {
                                        if (value == "" || value == null) {
                                          return "Password is required.";
                                        }
                                        return null;
                                      },
                                      prefix: Icon(Icons.lock_outline),
                                      controller: _passwordController,
                                      hintText: "Enter your password",
                                     
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
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                ValueListenableBuilder(
                                  valueListenable: _isLoading,
                                  builder: (context, isLoading, child) {
                                    return appButton(
                                      text: 'Continue',
                                      isLoading: isLoading,
                                      onPressed: loginUser,
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
                                          AppRouter.push(const SignupView());
                                        },
                                        child: Text(
                                          'Create Account',
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

  Future<void> loginUser() async {
    try {
      final isvalidated = _formkey.currentState?.validate() ?? false;

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
          .login(
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
