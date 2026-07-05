import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Dialog components for the AI Language Coach application.
/// Follows the Flutter Component Library specification.

/// Confirmation dialog.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }
}

/// Success dialog.
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'OK',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          child: Text(buttonLabel),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      ),
    );
  }
}

/// Error dialog.
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.buttonLabel = 'OK',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          child: Text(buttonLabel),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    String title = 'Error',
    required String message,
    String buttonLabel = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      ),
    );
  }
}

/// Subscription dialog.
class SubscriptionDialog extends StatelessWidget {
  final String planName;
  final String price;
  final List<String> features;
  final VoidCallback? onSubscribe;
  final VoidCallback? onRestore;

  const SubscriptionDialog({
    super.key,
    required this.planName,
    required this.price,
    this.features = const [],
    this.onSubscribe,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            color: theme.colorScheme.primary,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Upgrade to $planName',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            price,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.base),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRestore ?? () => Navigator.of(context).pop(),
          child: const Text('Restore Purchase'),
        ),
        ElevatedButton(
          onPressed: onSubscribe ?? () => Navigator.of(context).pop(true),
          child: const Text('Subscribe'),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String planName,
    required String price,
    List<String> features = const [],
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SubscriptionDialog(
        planName: planName,
        price: price,
        features: features,
      ),
    );
  }
}

/// Delete confirmation dialog.
class DeleteDialog extends StatelessWidget {
  final String itemName;
  final String? message;
  final VoidCallback? onDelete;

  const DeleteDialog({
    super.key,
    required this.itemName,
    this.message,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Delete $itemName',
      message: message ?? 'Are you sure you want to delete $itemName? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: onDelete,
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String itemName,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteDialog(
        itemName: itemName,
        message: message,
      ),
    );
  }
}

/// Permission dialog.
class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onGrant;
  final VoidCallback? onDeny;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.security,
    this.onGrant,
    this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDeny ?? () => Navigator.of(context).pop(false),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: onGrant ?? () => Navigator.of(context).pop(true),
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.security,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PermissionDialog(
        title: title,
        message: message,
        icon: icon,
      ),
    );
  }
}

/// Voice permission dialog.
class VoicePermissionDialog extends StatelessWidget {
  final VoidCallback? onGrant;
  final VoidCallback? onDeny;

  const VoicePermissionDialog({
    super.key,
    this.onGrant,
    this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionDialog(
      title: 'Microphone Access',
      message: 'AI Language Coach needs access to your microphone for voice practice and pronunciation exercises.',
      icon: Icons.mic,
      onGrant: onGrant,
      onDeny: onDeny,
    );
  }

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const VoicePermissionDialog(),
    );
  }
}

/// Logout dialog.
class LogoutDialog extends StatelessWidget {
  final VoidCallback? onLogout;

  const LogoutDialog({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      isDestructive: true,
      onConfirm: onLogout,
    );
  }

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const LogoutDialog(),
    );
  }
}

/// Language picker dialog.
class LanguagePicker extends StatelessWidget {
  final List<LanguageOption> languages;
  final String? selectedCode;
  final ValueChanged<String>? onSelected;

  const LanguagePicker({
    super.key,
    required this.languages,
    this.selectedCode,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Select Language'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            final isSelected = language.code == selectedCode;
            return ListTile(
              leading: Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(language.name),
              subtitle: Text(language.nativeName),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    )
                  : null,
              selected: isSelected,
              onTap: () {
                onSelected?.call(language.code);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }

  static Future<String?> show({
    required BuildContext context,
    required List<LanguageOption> languages,
    String? selectedCode,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => LanguagePicker(
        languages: languages,
        selectedCode: selectedCode,
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

/// Theme picker dialog.
class ThemePicker extends StatelessWidget {
  final AppThemeMode selectedTheme;
  final ValueChanged<AppThemeMode>? onSelected;

  const ThemePicker({
    super.key,
    this.selectedTheme = AppThemeMode.system,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeMode.values.map((mode) {
          return RadioListTile<AppThemeMode>(
            title: Text(_getThemeName(mode)),
            value: mode,
            groupValue: selectedTheme,
            onChanged: (value) {
              if (value != null) {
                onSelected?.call(value);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  static Future<AppThemeMode?> show({
    required BuildContext context,
    AppThemeMode selectedTheme = AppThemeMode.system,
  }) {
    return showDialog<AppThemeMode>(
      context: context,
      builder: (context) => ThemePicker(
        selectedTheme: selectedTheme,
      ),
    );
  }
}

enum AppThemeMode {
  system,
  light,
  dark,
}
