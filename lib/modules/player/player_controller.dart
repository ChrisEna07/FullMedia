import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class PlayerController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get player => _audioPlayer;

  double _volume = 1.0;
  double get volume => _volume;

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
  }

  // --- SELECCIÓN DE ARCHIVO ÚNICO (Para el botón "ARCHIVO") ---
  Future<PlatformFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'mp3',
          'wav',
          'm4a',
          'mp4',
          'mov',
          'mkv',
          'flac',
          'avi',
        ],
        withData: kIsWeb,
      );
      return result?.files.single;
    } catch (e) {
      debugPrint("Error en pickFile: $e");
      return null;
    }
  }

  // --- SELECCIÓN DE CARPETA (Híbrido: Carpeta en Nativo, Múltiple en Web) ---
  Future<List<PlatformFile>> pickDirectory() async {
    // Lógica específica para WEB (Simulamos carpeta permitiendo elegir varios archivos)
    if (kIsWeb) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'mp3',
            'wav',
            'm4a',
            'mp4',
            'mov',
            'mkv',
            'flac',
            'avi',
          ],
          allowMultiple: true,
          withData: true, // Necesario para obtener los bytes en Web
        );
        return result?.files ?? [];
      } catch (e) {
        debugPrint("Error en pickDirectory (Web): $e");
        return [];
      }
    }

    // Lógica para ANDROID / DESKTOP (Carpetas reales)
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return [];

      final directory = Directory(selectedDirectory);
      if (!await directory.exists()) return [];

      // Listamos los archivos de la carpeta
      final List<FileSystemEntity> entities = directory.listSync();
      List<PlatformFile> files = [];
      final List<String> supportedExt = [
        '.mp3',
        '.wav',
        '.m4a',
        '.mp4',
        '.mov',
        '.mkv',
        '.flac',
        '.avi',
      ];

      for (var entity in entities) {
        if (entity is File) {
          String path = entity.path;
          String name = path.split(Platform.pathSeparator).last;
          if (supportedExt.any((ext) => name.toLowerCase().endsWith(ext))) {
            files.add(
              PlatformFile(
                name: name,
                path: path,
                size: entity.lengthSync(),
                // En nativo no cargamos bytes aquí para no saturar la RAM
              ),
            );
          }
        }
      }
      return files;
    } catch (e) {
      debugPrint("Error en pickDirectory (Nativo): $e");
      return [];
    }
  }

  void toggleShuffle(bool enable) => _audioPlayer.setShuffleModeEnabled(enable);

  void setRepeatMode(String mode) {
    switch (mode) {
      case 'off':
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case 'one':
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case 'all':
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  void dispose() => _audioPlayer.dispose();
}
