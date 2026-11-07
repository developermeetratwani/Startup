import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

class CloudinaryService {
  final String cloudName;
  final String apiKey;
  final String apiSecret;
  final String uploadPreset;

  const CloudinaryService({
    this.cloudName = 'yjxpeklu',
    this.apiKey = '629954812314743',
    this.apiSecret = 'tmEEgZ4ruzWeKcuVFw1AIIUIEGQ',
    this.uploadPreset = 'hyperlocal_unsigned',
  });

  /// Upload image bytes directly to Cloudinary (using signed API upload)
  Future<(String?, Failure?)> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    String folder = 'products',
  }) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (apiKey.isNotEmpty && apiSecret.isNotEmpty) {
        // Authenticated Signed Upload (Uses user's Cloudinary API credentials)
        final paramsToSign = 'folder=$folder&timestamp=$timestamp$apiSecret';
        final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

        request.fields['api_key'] = apiKey;
        request.fields['timestamp'] = timestamp.toString();
        request.fields['folder'] = folder;
        request.fields['signature'] = signature;
      } else {
        // Unsigned fallback
        request.fields['upload_preset'] = uploadPreset;
        request.fields['folder'] = folder;
      }
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final secureUrl = data['secure_url'] as String?;
        AppLogger.info('CloudinaryService', 'Image uploaded successfully: $secureUrl');
        return (secureUrl, null);
      } else {
        AppLogger.error('CloudinaryService.uploadImageBytes', 'HTTP ${response.statusCode}: ${response.body}');
        return (null, ServerFailure('Cloudinary upload returned ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      AppLogger.error('CloudinaryService.uploadImageBytes', e.toString());
      return (null, ServerFailure(e.toString()));
    }
  }
}
