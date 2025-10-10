import 'dart:ui'; // Necesario para ImageFilter.blur
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final Map<String, int> _scannedCodes = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    final String code = capture.barcodes.first.rawValue ?? "";
    if (code.isEmpty) return;
    
    final now = DateTime.now();
    if (code == _lastScannedCode && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!) < const Duration(seconds: 2)) {
      return;
    }

    setState(() {
      _scannedCodes[code] = (_scannedCodes[code] ?? 0) + 1;
      _lastScannedCode = code;
      _lastScanTime = now;
    });

    _audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildScannedItemsList() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.33,
            color: Colors.white.withOpacity(0.1),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Historial de Escaneo',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _scannedCodes.keys.length,
                    itemBuilder: (context, index) {
                      final code = _scannedCodes.keys.elementAt(index);
                      final count = _scannedCodes[code];
                      return ListTile(
                        leading: const Icon(Icons.barcode_reader, color: Colors.white),
                        title: Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        trailing: CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 250,
      height: 200,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Modo Inventario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(_scannedCodes),
            tooltip: 'Finalizar Escaneo',
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            scanWindow: scanWindow,
            onDetect: _onBarcodeDetected,
          ),
          ScannerOverlay(scanWindow: scanWindow),
          LaserScannerAnimator(scanWindow: scanWindow),
          if (_scannedCodes.isNotEmpty) _buildScannedItemsList(),
        ],
      ),
    );
  }
}

class LaserScannerAnimator extends StatefulWidget {
  const LaserScannerAnimator({Key? key, required this.scanWindow}) : super(key: key);
  final Rect scanWindow;
  @override
  _LaserScannerAnimatorState createState() => _LaserScannerAnimatorState();
}

class _LaserScannerAnimatorState extends State<LaserScannerAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.scanWindow,
      child: CustomPaint(
        painter: _LaserPainter(_animation.value),
      ),
    );
  }
}

class _LaserPainter extends CustomPainter {
  final double animationValue;
  _LaserPainter(this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final laserPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.red.withOpacity(0.2), Colors.red, Colors.red.withOpacity(0.2)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 4));
    final yPos = size.height * animationValue;
    canvas.drawRect(Rect.fromLTWH(0, yPos - 2, size.width, 4), laserPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({Key? key, required this.scanWindow}) : super(key: key);
  final Rect scanWindow;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(scanWindow: scanWindow),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.scanWindow});
  final Rect scanWindow;
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;
    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final borderRect = RRect.fromRectAndRadius(scanWindow, const Radius.circular(8));
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}