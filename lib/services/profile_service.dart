import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/metadata.dart' show FlutterMetadata;
import 'package:sloth/src/rust/api/utils.dart' as utils_api;
import 'package:sloth/utils/mime_type.dart' show getMimeType;

class ProfileService {
  final String pubkey;

  const ProfileService(this.pubkey);

  Future<void> updateProfile({
    required String displayName,
    String? about,
    String? pictureUrl,
  }) async {
    final metadata = FlutterMetadata(
      displayName: displayName,
      about: about,
      picture: pictureUrl,
      custom: const {},
    );
    await accounts_api.updateAccountMetadata(pubkey: pubkey, metadata: metadata);
  }

  Future<String> uploadProfilePicture({
    required String filePath,
  }) async {
    final serverUrl = await utils_api.getDefaultBlossomServerUrl();
    final imageType = await getMimeType(filePath);
    if (imageType == null) {
      throw Exception('Failed to get image type');
    }
    return accounts_api.uploadAccountProfilePicture(
      pubkey: pubkey,
      serverUrl: serverUrl,
      filePath: filePath,
      imageType: imageType,
    );
  }
}
