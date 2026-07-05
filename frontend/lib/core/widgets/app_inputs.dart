import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_tokens.dart';

/// Input components for the AI Language Coach application.
/// Follows the Flutter Component Library specification.

/// Password field with show/hide toggle.
class PasswordField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final FocusNode? focusNode;

  const PasswordField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'Password',
        hintText: widget.hintText ?? 'Enter your password',
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

/// Search field with debounce support.
class SearchField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool enabled;

  const SearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.enabled = true,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller?.clear();
                  widget.onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }
}

/// OTP field for verification codes.
class OTPField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onComplete;
  final ValueChanged<String>? onChanged;

  const OTPField({
    super.key,
    this.length = 6,
    this.onComplete,
    this.onChanged,
  });

  @override
  State<OTPField> createState() => _OTPFieldState();
}

class _OTPFieldState extends State<OTPField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: Theme.of(context).textTheme.headlineSmall,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onChanged: (value) {
              widget.onChanged?.call(_getCode());
              if (value.isNotEmpty && index < widget.length - 1) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              if (_getCode().length == widget.length) {
                widget.onComplete?.call(_getCode());
              }
            },
          ),
        );
      }),
    );
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }
}

/// Email field with validation.
class EmailField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const EmailField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText ?? 'Email',
        hintText: hintText ?? 'Enter your email',
        errorText: errorText,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

/// Chat input field for AI conversations.
class ChatInput extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSend;
  final VoidCallback? onVoiceTap;
  final bool isLoading;
  final String hintText;

  const ChatInput({
    super.key,
    this.controller,
    this.onSend,
    this.onVoiceTap,
    this.isLoading = false,
    this.hintText = 'Type a message...',
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.onVoiceTap != null)
              IconButton(
                onPressed: widget.isLoading ? null : widget.onVoiceTap,
                icon: Icon(
                  Icons.mic,
                  color: theme.colorScheme.primary,
                ),
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !widget.isLoading,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    widget.onSend?.call(value.trim());
                    _controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: (_hasText && !widget.isLoading)
                  ? () {
                      widget.onSend?.call(_controller.text.trim());
                      _controller.clear();
                    }
                  : null,
              icon: Icon(
                Icons.send,
                color: _hasText
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Essay input field for writing tasks.
class EssayInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final int? maxLength;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const EssayInput({
    super.key,
    this.controller,
    this.hintText,
    this.maxLength,
    this.maxLines = 15,
    this.onChanged,
    this.validator,
  });

  @override
  State<EssayInput> createState() => _EssayInputState();
}

class _EssayInputState extends State<EssayInput> {
  late TextEditingController _controller;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _charCount = _controller.text.length;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _charCount = _controller.text.length;
    });
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: _controller,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Write your essay here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignLabelWithHint: true,
          ),
        ),
        if (widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '$_charCount / ${widget.maxLength}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _charCount > (widget.maxLength! * 0.9)
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Rich text editor with basic formatting.
class RichTextEditor extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const RichTextEditor({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController _controller;
  bool _isBold = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.format_bold,
                  color: _isBold ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  setState(() {
                    _isBold = !_isBold;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.format_italic,
                  color: _isItalic ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  setState(() {
                    _isItalic = !_isItalic;
                  });
                },
              ),
            ],
          ),
        ),
        TextFormField(
          controller: _controller,
          maxLines: 10,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Write here...',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.md),
              ),
            ),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
