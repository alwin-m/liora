import 'package:flutter/material.dart';
import 'theme.dart';

/// Android 16-Inspired Custom Components
/// Calm, minimal, system-blended UI widgets

/// Soft card container with blur-based elevation
class SoftContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final Function()? onTap;

  const SoftContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.lg),
    this.blur = 8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: AppTheme.roundedMd,
          boxShadow: AppTheme.shadowSm,
        ),
        child: child,
      ),
    );
  }
}

/// Minimalist elevated button with smooth animation
class MinimalButton extends StatefulWidget {
  final String label;
  final Function() onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const MinimalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<MinimalButton> createState() => _MinimalButtonState();
}

class _MinimalButtonState extends State<MinimalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.durationSm,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.easeInOutSmooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : _onTapDown,
        onTapUp: widget.isLoading ? null : _onTapUp,
        onTapCancel: widget.isLoading ? null : _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.xl,
            vertical: AppTheme.lg,
          ),
          decoration: BoxDecoration(
            color: widget.isSecondary ? Colors.transparent : AppTheme.primary,
            border: widget.isSecondary
                ? Border.all(color: AppTheme.primary, width: 1.5)
                : null,
            borderRadius: AppTheme.roundedMd,
            boxShadow: widget.isSecondary ? [] : AppTheme.shadowSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isSecondary ? AppTheme.primary : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.md),
              ],
              if (widget.isLoading)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isSecondary ? AppTheme.primary : Colors.white,
                    ),
                  ),
                )
              else
                Text(
                  widget.label,
                  style: AppTheme.labelLarge.copyWith(
                    color: widget.isSecondary ? AppTheme.primary : Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Input field with calm focus state
class MinimalTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const MinimalTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<MinimalTextField> createState() => _MinimalTextFieldState();
}

class _MinimalTextFieldState extends State<MinimalTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.md),
        AnimatedContainer(
          duration: AppTheme.durationSm,
          decoration: BoxDecoration(
            color: _isFocused ? AppTheme.surfaceContainerHigh : AppTheme.surfaceContainer,
            borderRadius: AppTheme.roundedMd,
            border: _isFocused
                ? Border.all(color: AppTheme.primary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            boxShadow: _isFocused ? AppTheme.shadowSm : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            style: AppTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
              border: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppTheme.primary)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? Icon(widget.suffixIcon, color: AppTheme.textTertiary)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.lg,
                vertical: AppTheme.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Smooth progress indicator
class SmoothProgressIndicator extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;

  const SmoothProgressIndicator({
    super.key,
    required this.value,
    this.backgroundColor = AppTheme.surfaceContainerHigh,
    this.valueColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTheme.roundedSm,
      ),
      child: FractionallySizedBox(
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: valueColor,
            borderRadius: AppTheme.roundedSm,
          ),
        ),
      ),
    );
  }
}

/// Calm toast/snack bar notification
void showCalmSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: AppTheme.md),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.textPrimary.withOpacity(0.85),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppTheme.lg),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedMd),
      duration: duration,
    ),
  );
}

/// Smooth page transition
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;

  SmoothPageTransition({required this.page})
      : super(
          transitionDuration: AppTheme.durationMd,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 0.0, end: 1.0)
                    .chain(CurveTween(curve: AppTheme.easeOutSmooth)),
              ),
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0.1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: AppTheme.easeOutSmooth)),
                ),
                child: child,
              ),
            );
          },
        );
}

/// Expandable section with smooth animation
class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: AppTheme.durationMd,
      vsync: this,
      value: _isExpanded ? 1 : 0,
    );
    _heightFactor = _controller.drive(
      CurveTween(curve: AppTheme.easeInOutSmooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.lg),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: AppTheme.roundedMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: AppTheme.headlineSmall),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5)
                      .animate(_heightFactor),
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _heightFactor,
            axisAlignment: -1,
            child: Container(
              margin: const EdgeInsets.only(top: AppTheme.md),
              padding: const EdgeInsets.all(AppTheme.lg),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: AppTheme.roundedMd,
              ),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
