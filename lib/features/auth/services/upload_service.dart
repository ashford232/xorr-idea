import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:xorr/features/auth/configs/client_config.dart';
import 'package:xorr/features/auth/configs/upload_service_config.dart';

class UploadService {
  final Client client;

  UploadService({required this.client});

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickProfilePicture() {
    return _picker.pickImage(source: ImageSource.gallery);
  }

Future<Map<String, String>?> getProfilePictureUploadUrl() async {
  final response = await client.post(
    UploadServiceConfig.profilePictureEndpoint,
    body: {'contentType': 'image/jpeg'},
  );

  if (response.statusCode != 200) {
    return null;
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  return {
    'uploadUrl': data['uploadUrl'] as String,
    'publicUrl': data['publicUrl'] as String,
  };
}

Future<String?> uploadProfilePicture(XFile image) async {
  final urls = await getProfilePictureUploadUrl();

  if (urls == null) {
    return null;
  }

  final bytes = await image.readAsBytes();

  final response = await http.put(
    Uri.parse(urls['uploadUrl']!),
    headers: {
      'Content-Type': image.mimeType ?? 'image/jpeg',
    },
    body: bytes,
  );

  if (response.statusCode != 200) {
    return null;
  }

  return urls['publicUrl'];
}

}
