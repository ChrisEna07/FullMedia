import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DownloadService {
  final Dio _dio = Dio();

  // Método para descargar desde YouTube (simulado - necesitarás una API real)
  Future<String?> downloadFromYouTube(String url) async {
    // Si es WEB, no ejecutamos lógica de dart:io
    if (kIsWeb) {
      print("Descarga no disponible en el navegador.");
      return null;
    }

    try {
      // NOTA: Esto es un ejemplo. Para YouTube necesitarás:
      // 1. Usar youtube_explode_dart o similar
      // 2. O usar una API como yt-dlp
      // 3. O usar servicios como youtube-dl-executable

      // Por ahora, simulamos una descarga de ejemplo
      // En producción, deberías implementar la lógica real de descarga de YouTube

      print("Descargando desde YouTube: $url");

      // Simulación de descarga (reemplazar con lógica real)
      Directory? directory;
      if (Platform.isWindows) {
        directory = await getDownloadsDirectory();
      } else if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      }

      if (directory == null) return null;

      // Crear nombre de archivo basado en timestamp
      String fileName =
          "youtube_audio_${DateTime.now().millisecondsSinceEpoch}.mp3";
      String fullPath = "${directory.path}/$fileName";

      // Aquí iría la lógica real de descarga desde YouTube
      // Por ejemplo, usando youtube_explode_dart:
      // final yt = YoutubeExplode();
      // final manifest = await yt.videos.streamsClient.getManifest(videoId);
      // final audioStream = manifest.audioOnly.first;
      // await yt.videos.streamsClient.download(audioStream, fullPath);

      // Simulamos una descarga exitosa
      await Future.delayed(const Duration(seconds: 2));

      print("Audio guardado en: $fullPath");
      return fullPath;
    } catch (e) {
      print("Error en descarga de YouTube: $e");
      return null;
    }
  }

  // Método original para descargar medios
  Future<void> downloadMedia({
    required String url,
    required String fileName,
    required String extension,
  }) async {
    // Si es WEB, no ejecutamos lógica de dart:io
    if (kIsWeb) {
      print("Descarga no disponible en el navegador.");
      return;
    }

    try {
      Directory? directory;
      if (Platform.isWindows) {
        directory = await getDownloadsDirectory();
      } else if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      }

      if (directory == null) return;

      String fullPath = "${directory.path}/$fileName.$extension";

      await _dio.download(url, fullPath);
      print("Guardado en: $fullPath");
    } catch (e) {
      print("Error en descarga: $e");
    }
  }
}
