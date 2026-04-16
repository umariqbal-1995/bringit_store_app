import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Uploads [file] to Firebase Storage under [folder] and returns the download URL.
  static Future<String> uploadFile(File file, String folder) async {
    final filePath = file.path;
    final lastDot = filePath.lastIndexOf('.');
    final ext = lastDot != -1 ? filePath.substring(lastDot) : '.jpg';
    final fileName = '${folder}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final ref = _storage.ref().child(folder).child(fileName);
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
}
