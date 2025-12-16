import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/utils/formatting.dart' show formatInitials;

class WnAvatar extends StatelessWidget {
  const WnAvatar({
    super.key,
    this.pictureUrl,
    this.displayName,
    this.size,
  });

  final String? pictureUrl;
  final String? displayName;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatarSize = size ?? 44.w;

    if (pictureUrl?.isNotEmpty ?? false) {
      return SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: Image.network(
          key: const Key('avatar_image'),
          pictureUrl!,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            final imageWithBorder = Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.foregroundTertiary, width: 1.5),
              ),
              child: ClipOval(child: child),
            );
            if (wasSynchronouslyLoaded) return imageWithBorder;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: imageWithBorder,
            );
          },
          errorBuilder: (context, error, stackTrace) => _InitialsAvatar(
            displayName: displayName,
            size: avatarSize,
          ),
        ),
      );
    }

    return _InitialsAvatar(displayName: displayName, size: avatarSize);
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    this.displayName,
    required this.size,
  });

  final String? displayName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = formatInitials(displayName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.backgroundSecondary.withValues(alpha: 0.4),
        border: Border.all(color: colors.foregroundTertiary, width: 1.5),
      ),
      child: Center(
        child: initials != null
            ? Text(
                initials,
                style: TextStyle(
                  color: colors.foregroundSecondary,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                ),
              )
            : SvgPicture.asset(
                key: const Key('avatar_fallback_icon'),
                'assets/svgs/user.svg',
                width: size * 0.4,
                height: size * 0.4,
                colorFilter: ColorFilter.mode(
                  colors.foregroundSecondary,
                  BlendMode.srcIn,
                ),
              ),
      ),
    );
  }
}
