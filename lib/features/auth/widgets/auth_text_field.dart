import 'package:flutter/material.dart';
import '../../../core/theme/liora_theme.dart';

/// Custom text field with LIORA styling
///
/// Features:
/// - Soft, rounded design
/// - Gentle animations
/// - Password visibility toggle
/// - Inline validation
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: LioraTextStyles.label.copyWith(
              color:
                  _isFocused ? LioraColors.deepRose : LioraColors.textSecondary,
            ),
          ),
        ),

        // Text Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LioraRadius.large),
            boxShadow: _isFocused ? LioraShadows.soft : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: LioraTextStyles.bodyLarge,
            onFieldSubmitted: widget.onSubmitted,
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() => _errorText = error);
              return error;
            },
            onTap: () => setState(() => _isFocused = true),
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              setState(() => _isFocused = false);
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LioraRadius.large),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LioraRadius.large),
                borderSide: BorderSide(
                  color: _errorText != null
                      ? LioraColors.error
                      : LioraColors.inputBorder,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LioraRadius.large),
                borderSide: const BorderSide(
                  color: LioraColors.accentRose,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LioraRadius.large),
                borderSide: const BorderSide(
                  color: LioraColors.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LioraRadius.large),
                borderSide: const BorderSide(
                  color: LioraColors.error,
                  width: 2,
                ),
              ),
              errorStyle: LioraTextStyles.bodySmall.copyWith(
                color: LioraColors.textSecondary,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: LioraColors.textMuted,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
