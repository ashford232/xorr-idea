import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xorr/features/auth/models/user_model.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/auth/wrappers/auth_wrapper.dart';
import 'package:xorr/shared/consts/app_consts.dart';
import 'package:xorr/shared/extensions/app_router.dart';
import 'package:xorr/shared/ui/buttons.dart';
import 'package:xorr/shared/ui/dialogs.dart';
import 'package:xorr/shared/ui/text_fields.dart';

class SetupView extends ConsumerStatefulWidget {
  final UserModel user;
  const SetupView({super.key, required this.user});

  @override
  ConsumerState<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends ConsumerState<SetupView> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final ValueNotifier<XFile?> _selectedImage = ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadService = ref.read(uploadServiceProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
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
                              const SizedBox(height: 10),
                              Text(
                                'Setup your account for ${widget.user.email}',
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 10),
                              ValueListenableBuilder(
                                valueListenable: _selectedImage,
                                builder: (context, selectedImage, child) {
                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final res = await uploadService
                                            .pickProfilePicture();

                                        if (res != null) {
                                          _selectedImage.value = res;
                                        }
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        clipBehavior: .hardEdge,
                                        decoration: BoxDecoration(
                                          shape: .circle,
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                        ),
                                        child: selectedImage != null
                                            ? Image.file(
                                                File(selectedImage.path),
                                                fit: .cover,
                                              )
                                            : Icon(Icons.camera_alt),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),

                              appTextField(
                                prefix: Icon(Icons.person_outline),
                                controller: _usernameController,
                                hintText: "Username",
                                onPressed: () {},
                                autofillHints: {AutofillHints.name},
                                textInputType: .name,

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Username is requied.";
                                  }

                                  if (value.length < 2) {
                                    return "Enter a valid username.";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              ValueListenableBuilder(
                                valueListenable: _isLoading,
                                builder: (context, isLoading, child) {
                                  return appButton(
                                    text: 'Continue',
                                    isLoading: isLoading,
                                    onPressed: setupUser,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,

                                    child: GestureDetector(
                                      onTap: logout,
                                      child: Text(
                                        'Logout',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
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
    );
  }

  Future<void> setupUser() async {
    try {
      final isvalidated = _formkey.currentState?.validate() ?? false;

      if (!isvalidated || _selectedImage.value == null) {
        return;
      }
      final res = await DesktopDialogs.confirm(
        context,
        title: "Is this the correct username?",
        message: _usernameController.text,
      );
      if (!res) {
        return;
      }
      _isLoading.value = true;
      final uploadService = ref.read(uploadServiceProvider);

      final url = await uploadService.uploadProfilePicture(
        _selectedImage.value!,
      );

      if (url == null) {
        if (mounted) {
          await DesktopDialogs.error(
            context,
            message: "Something went wrong, please try again.",
          );
        }
        return;
      } else {
        final authRepository = ref.read(authRepositoryProvider);
        final result = await authRepository.updateUser(
          data: UserModel(
            email: widget.user.email,
            photoUrl: url,
            username: _usernameController.text.trim(),
            uid: null,
            createdAt: null,
            updatedAt: null,
          ),
        );
        if (mounted) {
          if (result.status == true) {
            ref.invalidate(getUserProvider);
            AppRouter.to(AuthWrapper());
          } else {
            DesktopDialogs.error(
              context,
              message: "Something went wrong, please try again.",
            );
          }
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

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.invalidate(getUserProvider);
  }
}
