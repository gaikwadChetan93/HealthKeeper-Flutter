import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';

/// A from-scratch crop/rotate step — deliberately simpler than a full
/// perspective-correcting scanner: an adjustable rectangle (drag any
/// corner) plus 90° rotation, applied with the `image` package. No native
/// cropper plugin, so no extra Android/iOS setup beyond the camera itself.
///
/// Returns the path to the cropped file, or null if the user backs out
/// (caller should then drop that captured page).
class CropScreen extends StatefulWidget {
  final String imagePath;
  const CropScreen({super.key, required this.imagePath});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  late String _path = widget.imagePath;
  img.Image? _decoded;
  bool _loading = true;
  bool _busy = false;

  // Crop rectangle in *display* coordinates, set once the image is decoded
  // and the display box size is known.
  Rect? _rect;
  Size? _displaySize;

  static const double _handleSize = 26;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    setState(() => _loading = true);
    final bytes = await File(_path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    setState(() {
      _decoded = decoded;
      _loading = false;
      _rect = null; // recomputed once display size is known
    });
  }

  void _initRectIfNeeded(Size displaySize) {
    if (_rect != null && _displaySize == displaySize) return;
    _displaySize = displaySize;
    final inset = displaySize.shortestSide * 0.08;
    _rect = Rect.fromLTWH(
      inset,
      inset,
      displaySize.width - inset * 2,
      displaySize.height - inset * 2,
    );
  }

  Future<void> _rotate() async {
    if (_decoded == null || _busy) return;
    setState(() => _busy = true);
    final rotated = img.copyRotate(_decoded!, angle: 90);
    final dir = await getApplicationDocumentsDirectory();
    final newPath = '${dir.path}/scans/rot_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(newPath).parent.create(recursive: true);
    await File(newPath).writeAsBytes(img.encodeJpg(rotated, quality: 92));
    setState(() {
      _path = newPath;
      _busy = false;
    });
    await _decode();
  }

  Future<void> _confirm() async {
    if (_decoded == null || _rect == null || _displaySize == null || _busy) return;
    setState(() => _busy = true);

    final scaleX = _decoded!.width / _displaySize!.width;
    final scaleY = _decoded!.height / _displaySize!.height;
    final r = _rect!;
    final x = (r.left * scaleX).round().clamp(0, _decoded!.width - 1);
    final y = (r.top * scaleY).round().clamp(0, _decoded!.height - 1);
    final w = (r.width * scaleX).round().clamp(1, _decoded!.width - x);
    final h = (r.height * scaleY).round().clamp(1, _decoded!.height - y);

    final cropped = img.copyCrop(_decoded!, x: x, y: y, width: w, height: h);
    final Uint8List bytes = img.encodeJpg(cropped, quality: 92);
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/scans/page_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(path).parent.create(recursive: true);
    await File(path).writeAsBytes(bytes);

    if (mounted) Navigator.of(context).pop(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkStrong,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Text('Adjust crop', style: AppTypography.button.copyWith(color: Colors.white)),
                  IconButton(
                    onPressed: _busy ? null : _rotate,
                    icon: const Icon(Icons.rotate_right, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: _loading || _decoded == null
                    ? const CircularProgressIndicator(color: Colors.white)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final aspect = _decoded!.width / _decoded!.height;
                          final maxW = constraints.maxWidth;
                          final maxH = constraints.maxHeight;
                          var w = maxW;
                          var h = w / aspect;
                          if (h > maxH) {
                            h = maxH;
                            w = h * aspect;
                          }
                          final displaySize = Size(w, h);
                          _initRectIfNeeded(displaySize);

                          return SizedBox(
                            width: w,
                            height: h,
                            child: Stack(
                              children: [
                                Positioned.fill(child: Image.file(File(_path), fit: BoxFit.fill)),
                                Positioned.fill(
                                  child: CustomPaint(painter: _CropOverlayPainter(_rect!)),
                                ),
                                ..._buildHandles(displaySize),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusTileS)),
                      ),
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusTileS)),
                      ),
                      onPressed: _busy ? null : _confirm,
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Text('Use photo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHandles(Size displaySize) {
    final r = _rect!;
    final corners = <Alignment, Offset>{
      Alignment.topLeft: r.topLeft,
      Alignment.topRight: r.topRight,
      Alignment.bottomLeft: r.bottomLeft,
      Alignment.bottomRight: r.bottomRight,
    };

    return corners.entries.map((entry) {
      final align = entry.key;
      final point = entry.value;
      return Positioned(
        left: point.dx - _handleSize / 2,
        top: point.dy - _handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              var newRect = _rect!;
              final dx = details.delta.dx;
              final dy = details.delta.dy;
              const minSize = 60.0;

              if (align == Alignment.topLeft) {
                final left = (newRect.left + dx).clamp(0.0, newRect.right - minSize);
                final top = (newRect.top + dy).clamp(0.0, newRect.bottom - minSize);
                newRect = Rect.fromLTRB(left, top, newRect.right, newRect.bottom);
              } else if (align == Alignment.topRight) {
                final right = (newRect.right + dx).clamp(newRect.left + minSize, displaySize.width);
                final top = (newRect.top + dy).clamp(0.0, newRect.bottom - minSize);
                newRect = Rect.fromLTRB(newRect.left, top, right, newRect.bottom);
              } else if (align == Alignment.bottomLeft) {
                final left = (newRect.left + dx).clamp(0.0, newRect.right - minSize);
                final bottom = (newRect.bottom + dy).clamp(newRect.top + minSize, displaySize.height);
                newRect = Rect.fromLTRB(left, newRect.top, newRect.right, bottom);
              } else {
                final right = (newRect.right + dx).clamp(newRect.left + minSize, displaySize.width);
                final bottom = (newRect.bottom + dy).clamp(newRect.top + minSize, displaySize.height);
                newRect = Rect.fromLTRB(newRect.left, newRect.top, right, bottom);
              }
              _rect = newRect;
            });
          },
          child: Container(
            width: _handleSize,
            height: _handleSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect rect;
  const _CropOverlayPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Paint()..color = Colors.black.withValues(alpha: .55);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRect(rect);
    canvas.drawPath(Path.combine(PathOperation.difference, fullPath, holePath), outside);

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, border);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) => oldDelegate.rect != rect;
}
