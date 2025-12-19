import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/src/rust/api/welcomes.dart' show Welcome;
import 'package:sloth/widgets/wn_animated_avatar.dart';

class ChatListWelcomeTile extends HookWidget {
  final Welcome welcome;
  final VoidCallback? onTap;

  const ChatListWelcomeTile({
    super.key,
    required this.welcome,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final welcomerMetadataSnapshot = useUserMetadata(context, welcome.welcomer);
    final welcomerMetadata = welcomerMetadataSnapshot.data;
    final isLoading = welcomerMetadataSnapshot.connectionState == ConnectionState.waiting;

    final welcomerName = welcomerMetadata?.displayName ?? welcomerMetadata?.name;
    final hasGroupName = welcome.groupName.isNotEmpty;

    final String avatarDisplayName;
    final String? avatarPictureUrl;
    final String title;
    final String subtitle;

    if (hasGroupName) {
      avatarDisplayName = welcome.groupName;
      avatarPictureUrl = null;
      title = welcome.groupName;
      subtitle = welcomerName != null
          ? '$welcomerName invited you to a secure chat'
          : 'Someone invited you to a secure chat';
    } else {
      avatarDisplayName = welcomerName ?? '';
      avatarPictureUrl = welcomerMetadata?.picture;
      title = welcomerName ?? 'Unknown User';
      subtitle = 'Invited you to a secure chat';
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: isLoading
          ? const SizedBox.shrink()
          : ListTile(
              onTap: onTap,
              leading: WnAnimatedAvatar(
                pictureUrl: avatarPictureUrl,
                displayName: avatarDisplayName,
              ),
              title: Text(
                title,
                style: TextStyle(color: colors.foregroundPrimary),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(color: colors.foregroundTertiary),
              ),
            ),
    );
  }
}
