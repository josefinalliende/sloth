import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/extensions/build_context.dart';

class WnCopyableField extends StatelessWidget {
  const WnCopyableField({
    super.key,
    required this.label,
    required this.value,
    this.copiedMessage,
  });

  final String label;
  final String value;
  final String? copiedMessage;

  void _handleCopy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    if (copiedMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copiedMessage!),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.foregroundPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () => _handleCopy(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colors.backgroundPrimary,
              border: Border.all(color: colors.foregroundTertiary),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: colors.foregroundTertiary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.copy,
                  key: const Key('copy_button'),
                  color: colors.foregroundTertiary,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
