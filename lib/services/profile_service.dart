import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _nameKey = 'profile_name';
  static const String _avatarPathKey = 'profile_avatar_path';
  static const String _avatarBytesKey = 'profile_avatar_bytes';

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'Гость';
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = name.trim();
    await prefs.setString(
      _nameKey,
      trimmed.isEmpty ? 'Гость' : trimmed,
    );
  }

  Future<String?> getAvatarPath() async {
    if (kIsWeb) return null;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_avatarPathKey);
    if (path == null || path.isEmpty) return null;
    if (!File(path).existsSync()) return null;
    return path;
  }

  Future<Uint8List?> getAvatarBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_avatarBytesKey);
    if (raw == null || raw.isEmpty) return null;
    return base64Decode(raw);
  }

  Future<void> setAvatarBytes(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarBytesKey, base64Encode(bytes));

    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      final dest = File('${dir.path}/profile_avatar.jpg');
      await dest.writeAsBytes(bytes, flush: true);
      await prefs.setString(_avatarPathKey, dest.path);
    }
  }
}
