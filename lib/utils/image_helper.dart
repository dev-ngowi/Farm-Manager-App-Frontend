// lib/utils/image_helper.dart

import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ImageHelper {
  ImageHelper._();
  
  // Maximum file size (5MB as per backend validation)
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  
  // Recommended dimensions for profile photos (Used only by image_picker)
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const int imageQuality = 85;

  /// --- CORE FILE PICKING FUNCTIONS ---

  /// Pick a single file (Image or Document).
  /// Uses file_picker for documents (PDF/Image) and image_picker for standard profile photos.
  static Future<XFile?> pickFile({
    required ImageSource source, // Relevant primarily if isDocument is false
    bool isDocument = false,
  }) async {
    try {
      XFile? file;
      
      if (isDocument) {
        // 🚀 Use file_picker for robust document handling (PDF, etc.)
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          // Matches backend validation: pdf, jpg, jpeg, png
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: false, // Don't load file data directly into memory
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final platformFile = result.files.first;
          // Convert PlatformFile to XFile for downstream compatibility
          file = XFile(platformFile.path!);
        }
      } else {
        // Use image_picker for standard profile photos (respects source, quality)
        final ImagePicker picker = ImagePicker();
        file = await picker.pickImage(
          source: source,
          maxWidth: maxWidth.toDouble(),
          maxHeight: maxHeight.toDouble(),
          imageQuality: imageQuality,
        );
      }
      
      if (file != null) {
        // Validate file size
        final fileSize = await file.length();
        if (fileSize > maxFileSizeBytes) {
          throw Exception('File size must be less than 5MB');
        }
      }
      
      return file;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Pick multiple files (for Clinic Photos).
  /// Uses file_picker, restricted to images (FileType.image).
  static Future<List<XFile>> pickMultipleFiles() async {
    try {
      // 🚀 Using FilePicker for multi-file is generally safer and type-agnostic
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Restrict to images for clinic photos
        allowMultiple: true,
        withData: false,
      );
      
      List<XFile> files = [];

      if (result != null && result.files.isNotEmpty) {
        for (final platformFile in result.files) {
          // Convert PlatformFile to XFile
          files.add(XFile(platformFile.path!));
        }

        // Validate file sizes for all selected files
        for (final file in files) {
          final fileSize = await file.length();
          if (fileSize > maxFileSizeBytes) {
            throw Exception('One or more files exceed the 5MB limit.');
          }
        }
      }
      
      return files;
    } catch (e) {
      rethrow;
    }
  }

  /// --- BASE64 CONVERSION FUNCTIONS ---

  /// Convert XFile to Base64 string
  static Future<String> convertToBase64(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to encode file to Base64: $e');
    }
  }

  /// --- WORKFLOW FUNCTIONS (Pick + Convert) ---
  
  /// Full workflow: Pick a single file and convert to base64 string.
  /// Used for profile photos, certificates, and licenses.
  static Future<String?> pickAndConvertToBase64(
    ImageSource source, {
    bool isDocument = false,
  }) async {
    try {
      final file = await pickFile(source: source, isDocument: isDocument);
      if (file == null) return null;
      
      return await convertToBase64(file);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Full workflow: Pick multiple files and convert to a list of base64 strings.
  /// Used for clinic photos.
  static Future<List<String>> pickMultipleAndConvertToBase64() async {
    try {
      final files = await pickMultipleFiles();
      if (files.isEmpty) return [];
      
      final List<String> base64List = [];
      for (final file in files) {
        base64List.add(await convertToBase64(file));
      }
      return base64List;
    } catch (e) {
      rethrow;
    }
  }
  
  /// --- VALIDATION ---
  
  /// Validate file format based on expected types (jpg, jpeg, png, pdf)
  static bool isValidDocumentFormat(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'pdf'].contains(extension);
  }
}