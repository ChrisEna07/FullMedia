# 🎵 FULLMEDIA PRO

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

**FullMedia Pro** es un reproductor multimedia de alto rendimiento desarrollado en Flutter, diseñado para ofrecer una experiencia fluida tanto en audio como en video, con un enfoque en la personalización estética y el control total del usuario.

---

## 📸 Vista Previa

| Pantalla Principal | Selección de Archivos | Selección de Color |
| :---: | :---: | :---: |
| ![Principal](Screenshots/pantalla%20principal.png) | ![Selección](Screenshots/seleccion%20de%20archivos%20a%20reproducir.png) | ![Color](Screenshots/seleccion%20de%20color%20de%20reproductor.png) |

| Pantalla Reproduciendo Audio | Reproduciendo Video |
| :---: | :---: |
| ![Audio](Screenshots/pantalla%20reproduciendo%20audio.png) | ![Video](Screenshots/reproduciendo%20video.png) |

---

## ✨ Características Principales

* **🎼 Reproducción Versátil:** Soporte completo para formatos de audio (MP3, WAV, AAC) y video (MP4, MKV, MOV).
* **📉 Visualizador Dinámico:** Animaciones de ondas senoidales sincronizadas que reaccionan al estado de la música con movimientos suaves (`Curves.easeInOut`).
* **📱 Control en Segundo Plano:** Integración con `audio_service` para gestionar la música desde la barra de notificaciones y la pantalla de bloqueo.
* **🎨 Personalización:** Sistema de cambio de temas en tiempo real (Accent Colors) para adaptar la interfaz a tu estilo.
* **📂 Gestión de Biblioteca:** Importación masiva de archivos mediante selección de carpetas y persistencia de listas de reproducción con `shared_preferences`.
* **🎚️ Controles Avanzados:** Modos de aleatorio (shuffle), repetición (loop) y control de volumen integrado.

---

## 🛠️ Stack Tecnológico

* **Core:** [Flutter SDK](https://flutter.dev)
* **Audio Engine:** `just_audio` para un manejo preciso de fuentes de audio.
* **Background Actions:** `audio_service` para la persistencia en el sistema.
* **Video Player:** `video_player` + `chewie` (controles nativos).
* **Almacenamiento:** `shared_preferences` para guardar tu última playlist.
* **UI Components:** `audio_video_progress_bar` y animaciones personalizadas con `AnimatedBuilder`.

---

## 🚀 Instalación y Configuración

### 1. Requisitos previos
* Flutter 3.x instalado.
* Un dispositivo Android o emulador con API 21+.

### 2. Clonar el repositorio
```bash
git clone [https://github.com/tu-usuario/fullmedia-pro.git](https://github.com/tu-usuario/fullmedia-pro.git)
cd fullmedia-pro


3. Instalar dependencias

flutter pub get

4. Configuración de permisos (Android)
Asegúrate de que tu AndroidManifest.xml incluya los servicios de reproducción:

<service android:name="com.ryanheise.audioservice.AudioService"
         android:foregroundServiceType="mediaPlayback"
         android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>


🧬 Estructura del Proyecto
lib/player_screen.dart: Interfaz principal y visualizador.

lib/player_controller.dart: Lógica de negocio y gestión de estados.

lib/audio_handler.dart: Controlador de servicios en segundo plano.

lib/main.dart: Inicialización de servicios y la aplicación.


📄 Licencia
Distribuido bajo la Licencia MIT. Consulta el archivo LICENSE para más información.

Desarrollado con ❤️ por ChrisDev
