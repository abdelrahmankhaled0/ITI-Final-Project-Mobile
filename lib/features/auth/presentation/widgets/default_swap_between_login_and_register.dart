import 'package:flutter/material.dart';

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
              backgroundColor: Colors.transparent,
            ),
            child: Text(
              actionText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
