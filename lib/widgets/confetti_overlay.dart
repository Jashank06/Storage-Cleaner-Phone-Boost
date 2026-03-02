import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Confetti overlay for success celebrations
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  
  const ConfettiOverlay({
    super.key,
    required this.child,
    this.isPlaying = false,
  });
  
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }
  
  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _confettiController.play();
    }
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Color(0xFF00FF88),
              Color(0xFF10D97A),
              Color(0xFF20C96A),
              Colors.white,
              Color(0xFF0F172A),
            ],
          ),
        ),
      ],
    );
  }
}
