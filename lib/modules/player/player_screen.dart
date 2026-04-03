import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  final PlayerController _controller = PlayerController();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  late AnimationController _visualizerController;

  Color _accentColor = Colors.greenAccent;
  final List<PlatformFile> _playlist = [];
  int _currentIndex = -1;

  bool _isVideo = false;
  bool _isImage = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    // VELOCIDAD AJUSTADA: 1500ms para un movimiento suave y relajado
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _loadPlaylist();

    _controller.player.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.playing) {
        // reverse: true hace que el vaivén sea fluido de ida y vuelta
        _visualizerController.repeat(reverse: true);
      } else {
        _visualizerController.stop();
      }

      if (state.processingState == ProcessingState.completed) {
        _nextSong();
      }
      setState(() {});
    });
  }

  // ================== PERSISTENCIA ==================
  Future<void> _savePlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> paths = _playlist.map((file) => file.path ?? '').toList();
    await prefs.setString('playlist', jsonEncode(paths));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lista guardada correctamente")),
    );
  }

  Future<void> _loadPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('playlist');
    if (data != null) {
      List paths = jsonDecode(data);
      setState(() {
        _playlist.clear();
        for (var path in paths) {
          if (path.isNotEmpty) {
            _playlist.add(
              PlatformFile(
                name: path.split(Platform.pathSeparator).last,
                path: path,
                size: 0,
              ),
            );
          }
        }
        if (_playlist.isNotEmpty) _currentIndex = 0;
      });
    }
  }

  // ================== LÓGICA DE REPRODUCCIÓN ==================
  Future<void> _playCurrentMedia() async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return;

    final file = _playlist[_currentIndex];
    final name = file.name.toLowerCase();

    final isVideoFile = [
      '.mp4',
      '.mov',
      '.mkv',
      '.avi',
    ].any((e) => name.endsWith(e));
    final isImageFile = [
      '.jpg',
      '.png',
      '.jpeg',
      '.gif',
      '.webp',
    ].any((e) => name.endsWith(e));

    await _controller.player.stop();
    await _disposeVideoControllers();

    setState(() {
      _isVideo = isVideoFile;
      _isImage = isImageFile;
    });

    try {
      if (isImageFile) return;

      if (isVideoFile) {
        _videoPlayerController = kIsWeb
            ? VideoPlayerController.networkUrl(
                Uri.dataFromBytes(file.bytes!, mimeType: 'video/mp4'),
              )
            : VideoPlayerController.file(File(file.path!));

        await _videoPlayerController!.initialize();
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
          );
        });
      } else {
        await _controller.player.setAudioSource(AudioSource.file(file.path!));
        _controller.player.setVolume(_volume);
        _controller.player.play();
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  // ================== UI PRINCIPAL ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text(
          "FULLMEDIA PRO",
          style: TextStyle(fontSize: 16, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: _showThemeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.graphic_eq_rounded),
            onPressed: _showEqDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          _buildViewer(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _currentIndex != -1
                  ? _playlist[_currentIndex].name
                  : "Sin reproducción",
              style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (!_isImage) _buildVolume(),
          _buildProgress(),
          _buildControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildViewer() {
    if (_currentIndex == -1)
      return const Icon(
        Icons.music_note_rounded,
        size: 120,
        color: Colors.white10,
      );
    if (_isImage)
      return Container(
        height: 250,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            File(_playlist[_currentIndex].path!),
            fit: BoxFit.contain,
          ),
        ),
      );
    if (_isVideo) {
      return SizedBox(
        height: 250,
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      );
    }

    // --- VISUALIZADOR ANIMADO SUAVE ---
    return SizedBox(
      height: 120,
      child: AnimatedBuilder(
        animation: _visualizerController,
        builder: (context, child) {
          // Usamos una curva easeInOut para que el movimiento sea orgánico
          final curvedValue = CurvedAnimation(
            parent: _visualizerController,
            curve: Curves.easeInOut,
          ).value;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(15, (i) {
              // Altura base aleatoria pero constante para cada barra
              double baseHeight = (math.Random(i).nextInt(40) + 20).toDouble();

              // Cálculo de onda senoidal suave basada en el valor curvo
              double wave =
                  math.sin(curvedValue * math.pi + (i * 0.4)) * 0.5 + 0.5;
              double finalHeight = _controller.player.playing
                  ? baseHeight + (wave * 50)
                  : 12.0;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: finalHeight,
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(
                    _controller.player.playing ? 1.0 : 0.4,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    if (_controller.player.playing)
                      BoxShadow(
                        color: _accentColor.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: StreamBuilder<Duration>(
        stream: _controller.player.positionStream,
        builder: (_, s) => ProgressBar(
          progress: s.data ?? Duration.zero,
          total: _controller.player.duration ?? Duration.zero,
          onSeek: (d) => _controller.player.seek(d),
          progressBarColor: _accentColor,
          baseBarColor: Colors.white10,
          thumbColor: _accentColor,
          timeLabelTextStyle: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildVolume() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const Icon(Icons.volume_mute, color: Colors.white38, size: 18),
          Expanded(
            child: Slider(
              value: _volume,
              activeColor: _accentColor,
              onChanged: (v) {
                setState(() => _volume = v);
                _controller.player.setVolume(v);
              },
            ),
          ),
          const Icon(Icons.volume_up, color: Colors.white38, size: 18),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildShuffle(),
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            size: 40,
            color: Colors.white,
          ),
          onPressed: _previousSong,
        ),
        GestureDetector(
          onTap: () {
            _controller.player.playing
                ? _controller.player.pause()
                : _controller.player.play();
            setState(() {});
          },
          child: CircleAvatar(
            radius: 35,
            backgroundColor: _accentColor,
            child: Icon(
              _controller.player.playing
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 45,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            size: 40,
            color: Colors.white,
          ),
          onPressed: _nextSong,
        ),
        _buildRepeat(),
      ],
    );
  }

  // ================== DIÁLOGOS Y AUXILIARES ==================
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Seleccionar Color",
          style: TextStyle(color: Colors.white),
        ),
        content: Wrap(
          spacing: 10,
          children:
              [
                    Colors.greenAccent,
                    Colors.blueAccent,
                    Colors.redAccent,
                    Colors.orangeAccent,
                    Colors.purpleAccent,
                  ]
                  .map(
                    (c) => GestureDetector(
                      onTap: () {
                        setState(() => _accentColor = c);
                        Navigator.pop(ctx);
                      },
                      child: CircleAvatar(backgroundColor: c),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  void _showEqDialog() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Ecualizador próximamente")));
  }

  Widget _buildShuffle() {
    return StreamBuilder<bool>(
      stream: _controller.player.shuffleModeEnabledStream,
      builder: (_, s) {
        final enabled = s.data ?? false;
        return IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: enabled ? _accentColor : Colors.white38,
          ),
          onPressed: () => _controller.player.setShuffleModeEnabled(!enabled),
        );
      },
    );
  }

  Widget _buildRepeat() {
    return StreamBuilder<LoopMode>(
      stream: _controller.player.loopModeStream,
      builder: (_, s) {
        final mode = s.data ?? LoopMode.off;
        IconData icon = Icons.repeat_rounded;
        Color color = (mode != LoopMode.off) ? _accentColor : Colors.white38;
        if (mode == LoopMode.one) icon = Icons.repeat_one_rounded;
        return IconButton(
          icon: Icon(icon, color: color),
          onPressed: () {
            if (mode == LoopMode.off)
              _controller.player.setLoopMode(LoopMode.all);
            else if (mode == LoopMode.all)
              _controller.player.setLoopMode(LoopMode.one);
            else
              _controller.player.setLoopMode(LoopMode.off);
          },
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                "BIBLIOTECA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_open, color: Colors.white70),
            title: const Text("Archivo", style: TextStyle(color: Colors.white)),
            onTap: _pickFiles,
          ),
          ListTile(
            leading: const Icon(Icons.folder_copy, color: Colors.white70),
            title: const Text("Carpeta", style: TextStyle(color: Colors.white)),
            onTap: _pickFolder,
          ),
          ListTile(
            leading: const Icon(Icons.save, color: Colors.white70),
            title: const Text(
              "Guardar Lista",
              style: TextStyle(color: Colors.white),
            ),
            onTap: _savePlaylist,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              "Vaciar Lista",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () => setState(() {
              _playlist.clear();
              _currentIndex = -1;
              _controller.player.stop();
            }),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView.builder(
              itemCount: _playlist.length,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                title: Text(
                  _playlist[i].name,
                  style: TextStyle(
                    color: _currentIndex == i ? _accentColor : Colors.white60,
                  ),
                ),
                onTap: () {
                  setState(() => _currentIndex = i);
                  _playCurrentMedia();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _playlist.addAll(result.files);
        if (_currentIndex == -1) _currentIndex = 0;
      });
      _playCurrentMedia();
    }
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    final dir = Directory(result);
    final files = dir.listSync();
    setState(() {
      for (var f in files) {
        if (f is File) {
          _playlist.add(
            PlatformFile(
              name: f.path.split(Platform.pathSeparator).last,
              path: f.path,
              size: 0,
            ),
          );
        }
      }
      if (_currentIndex == -1 && _playlist.isNotEmpty) _currentIndex = 0;
    });
    _playCurrentMedia();
  }

  void _nextSong() {
    if (_playlist.isEmpty) return;
    setState(() => _currentIndex = (_currentIndex + 1) % _playlist.length);
    _playCurrentMedia();
  }

  void _previousSong() {
    if (_playlist.isEmpty) return;
    setState(
      () => _currentIndex =
          (_currentIndex - 1 + _playlist.length) % _playlist.length,
    );
    _playCurrentMedia();
  }

  Future<void> _disposeVideoControllers() async {
    _chewieController?.dispose();
    await _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    _disposeVideoControllers();
    _controller.dispose();
    super.dispose();
  }
}
