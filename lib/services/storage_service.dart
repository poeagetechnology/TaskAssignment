import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage service for image uploads and management
class StorageService {
  static const String tasksImagesPath = 'tasks_images';
  static const String dprImagesPath = 'dpr_images';
  static const String profileImagesPath = 'profile_images';

  late FirebaseStorage _storage;

  StorageService() {
    try {
      // Always initialize instance
      _storage = FirebaseStorage.instance;
      debugPrint('✅ FirebaseStorage instance created');
    } catch (e) {
      debugPrint('⚠️ FirebaseStorage not available: $e');
      // In web/dev mode, FirebaseStorage might not work
    }
  }

  /// Upload task image (Before/After proof)
  Future<String> uploadTaskImage({
    required File imageFile,
    required String taskId,
    required String imageType, // 'before' or 'after'
  }) async {
    try {
      final fileName = _generateFileName(imageType);
      final ref = _storage
          .ref()
          .child(tasksImagesPath)
          .child(taskId)
          .child(fileName);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload task image: $e');
    }
  }

  /// Upload multiple task images
  Future<List<String>> uploadTaskImages({
    required List<File> imageFiles,
    required String taskId,
  }) async {
    try {
      final urls = <String>[];
      for (var imageFile in imageFiles) {
        final url = await uploadTaskImage(
          imageFile: imageFile,
          taskId: taskId,
          imageType: 'document',
        );
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload task images: $e');
    }
  }

  /// Upload DPR image
  Future<String> uploadDprImage({
    required File imageFile,
    required String dprId,
  }) async {
    try {
      final fileName = _generateFileName('dpr');
      final ref = _storage
          .ref()
          .child(dprImagesPath)
          .child(dprId)
          .child(fileName);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload DPR image: $e');
    }
  }

  /// Upload multiple DPR images
  Future<List<String>> uploadDprImages({
    required List<File> imageFiles,
    required String dprId,
  }) async {
    try {
      final urls = <String>[];
      for (var imageFile in imageFiles) {
        final url = await uploadDprImage(imageFile: imageFile, dprId: dprId);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload DPR images: $e');
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage
          .ref()
          .child(profileImagesPath)
          .child(userId)
          .child(fileName);

      await ref.putFile(imageFile);

      // Delete old profile pictures
      await _deleteOldProfilePictures(userId, fileName);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete multiple images
  Future<void> deleteImages(List<String> imageUrls) async {
    try {
      for (var url in imageUrls) {
        await deleteImage(url);
      }
    } catch (e) {
      throw Exception('Failed to delete images: $e');
    }
  }

  /// Get download URL for an image
  Future<String> getDownloadUrl(String imagePath) async {
    try {
      return await _storage.ref(imagePath).getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// List all images in a directory
  Future<List<String>> listImages(String directoryPath) async {
    try {
      final result = await _storage.ref(directoryPath).listAll();
      final urls = <String>[];

      for (var ref in result.items) {
        final url = await ref.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to list images: $e');
    }
  }

  /// Get storage metadata
  Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get image metadata: $e');
    }
  }

  // Private helper methods

  /// Generate a unique filename for uploaded images
  String _generateFileName(String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${type}_$timestamp.jpg';
  }

  /// Delete old profile pictures to maintain storage efficiency
  Future<void> _deleteOldProfilePictures(
    String userId,
    String currentFileName,
  ) async {
    try {
      final ref = _storage.ref(profileImagesPath).child(userId);
      final result = await ref.listAll();

      for (var item in result.items) {
        if (item.name != currentFileName) {
          await item.delete();
        }
      }
    } catch (e) {
      // Silently fail for cleanup operations
    }
  }
}
