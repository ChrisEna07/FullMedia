import 'package:flutter/material.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  // 5 bandas típicas de un ecualizador
  List<double> bandValues = [0.0, 0.0, 0.0, 0.0, 0.0];
  final List<String> labels = ["60Hz", "230Hz", "910Hz", "3kHz", "14kHz"];

  void _applyPreset(String type) {
    setState(() {
      switch (type) {
        case 'Rock':
          bandValues = [4.5, 2.0, -1.5, 2.0, 4.0];
          break;
        case 'Pop':
          bandValues = [-1.5, 1.5, 3.0, 1.5, -1.0];
          break;
        case 'Bass':
          bandValues = [7.0, 3.5, 0.0, 0.0, 0.0];
          break;
        case 'Jazz':
          bandValues = [3.0, 0.0, 1.5, 2.5, 3.5];
          break;
        default:
          bandValues = [0.0, 0.0, 0.0, 0.0, 0.0]; // Flat
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("ECUALIZADOR PRO"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Chips de Presets
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Flat', 'Rock', 'Pop', 'Bass', 'Jazz']
                  .map(
                    (preset) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ActionChip(
                        label: Text(
                          preset,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blueAccent.withOpacity(0.3),
                        onPressed: () => _applyPreset(preset),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => Column(
                  children: [
                    Text(
                      "${bandValues[index].toInt()}dB",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 10,
                      ),
                    ),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Slider(
                          value: bandValues[index],
                          min: -10.0,
                          max: 10.0,
                          activeColor: Colors.blueAccent,
                          onChanged: (val) =>
                              setState(() => bandValues[index] = val),
                        ),
                      ),
                    ),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
