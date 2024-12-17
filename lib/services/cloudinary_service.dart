// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dbrgxdfb7';
  static const String apiKey = '313573228491535';
  static const String apiSecret = 'E9C7rrUmGi11zPPx2BGpGdm601Y';
  static const String uploadPreset = 'ml_default';

  static Future<String> uploadFile(File file) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
    final mimeType = file.path.split('.').last == 'mp4' ? 'video' : 'image';

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(await response.stream.bytesToString());
      return jsonResponse['secure_url'];
    } else {
      throw Exception('Failed to upload file to Cloudinary');
    }
  }
}
