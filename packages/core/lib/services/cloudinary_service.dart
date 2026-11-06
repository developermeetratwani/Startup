import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  const CloudinaryService({
    this.cloudName = 'meet-hyperlocal',
    this.uploadPreset = 'hyperlocal_unsigned',
  });

  /// Upload image bytes directly to Cloudinary via unsigned upload
  Future<(String?, Failure?)> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    String folder = 'products',
  }) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      
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
        return (secureUrl, null);
      } else {
        AppLogger.error('CloudinaryService.uploadImageBytes', 'HTTP ${response.statusCode}: ${response.body}');
        return (null, ServerFailure('Cloudinary upload returned ${response.statusCode}'));
      }
    } catch (e) {
      AppLogger.error('CloudinaryService.uploadImageBytes', e.toString());
      return (null, ServerFailure(e.toString()));
    }
  }
}
