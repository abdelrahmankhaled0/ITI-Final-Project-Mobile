import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';

class DefaultSwapBetweenLoginAndRegister extends StatelessWidget {
  const DefaultSwapBetweenLoginAndRegister({
    super.key,
    required this.text,
    required this.actionText,
    this.onPressed,
    this.textStyle,
    this.actionStyle,
  });

  final String text;
  final String actionText;
  final VoidCallback? onPressed;

  final TextStyle? textStyle;
  final TextStyle? actionStyle;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = Theme.of(context).textTheme.bodyMedium;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(text, style: textStyle ?? defaultTextStyle),

          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style:
                  actionStyle ??
                  defaultTextStyle?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
