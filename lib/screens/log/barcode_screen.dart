import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/l10n.dart';
import '../../ui/kit.dart';

/// Full-screen barcode scanner. Returns the scanned barcode string via
/// [Navigator.pop] or pops with null if the user cancels.
class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  late final AnimationController _sweep;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    // The scan line only moves while the camera is open.
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.reduceMotion && !_sweep.isAnimating) {
      _sweep.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;
    _scanned = true;
    Navigator.of(context).pop(barcode);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          l10n.scanBarcodeTitle,
          style: PtText.headline(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Dim everything but the frame.
          Positioned.fill(
            child: IgnorePointer(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.55),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Align(
                      child: Container(
                        width: 270,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Pt.rMd),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Frame with corner marks and a sweeping scan line.
          Center(
            child: SizedBox(
              width: 270,
              height: 170,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _CornersPainter(p.fresh)),
                  ),
                  AnimatedBuilder(
                    animation: _sweep,
                    builder: (context, _) => Positioned(
                      left: 18,
                      right: 18,
                      top: 14 + (170 - 30) * Pt.ease.transform(_sweep.value),
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: p.fresh,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: p.fresh.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Text(
                    l10n.scanHint,
                    textAlign: TextAlign.center,
                    style: PtText.body(
                      color: Colors.white,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (_, state, child) {
                      final isTorchOn = state.torchState == TorchState.on;
                      return PtIconButton(
                        icon: isTorchOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        tooltip: l10n.torchTooltip,
                        background: isTorchOn
                            ? p.honey
                            : Colors.white.withValues(alpha: 0.18),
                        color: isTorchOn ? Colors.black : Colors.white,
                        size: 56,
                        iconSize: 26,
                        onPressed: () => _controller.toggleTorch(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  _CornersPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const l = 26.0;
    const r = 14.0;
    final w = size.width;
    final h = size.height;
    void corner(Offset o, double sx, double sy) {
      final path = Path()
        ..moveTo(o.dx, o.dy + sy * l)
        ..lineTo(o.dx, o.dy + sy * r)
        ..quadraticBezierTo(o.dx, o.dy, o.dx + sx * r, o.dy)
        ..lineTo(o.dx + sx * l, o.dy);
      canvas.drawPath(path, paint);
    }

    corner(const Offset(2, 2), 1, 1);
    corner(Offset(w - 2, 2), -1, 1);
    corner(Offset(2, h - 2), 1, -1);
    corner(Offset(w - 2, h - 2), -1, -1);
  }

  @override
  bool shouldRepaint(_CornersPainter old) => old.color != color;
}
