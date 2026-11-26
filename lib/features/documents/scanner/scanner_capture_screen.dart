import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/document_colors.dart';
import '../../../core/models/document.dart';
import '../../../core/state/module_providers.dart';
import 'crop_screen.dart';
import 'ocr_service.dart';

enum _CaptureStatus { loading, ready, denied, unavailable }

/// Live camera capture for the scanner: shutter → crop → repeat for more
/// pages → Done, which runs on-device OCR and files the result as a
/// [Document]. Multi-page, reorderable via long-press drag on the
/// thumbnail strip.
class ScannerCaptureScreen extends ConsumerStatefulWidget {
  final int memberId;
  const ScannerCaptureScreen({super.key, required this.memberId});

  @override
  ConsumerState<ScannerCaptureScreen> createState() => _ScannerCaptureScreenState();
}

class _ScannerCaptureScreenState extends ConsumerState<ScannerCaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  _CaptureStatus _status = _CaptureStatus.loading;
  final List<String> _pages = [];
  bool _capturing = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUpCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setUpCamera();
    }
  }

  Future<void> _setUpCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _status = _CaptureStatus.unavailable);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _status = _CaptureStatus.ready;
      });
    } on CameraException catch (_) {
      if (mounted) setState(() => _status = _CaptureStatus.denied);
    } catch (_) {
      if (mounted) setState(() => _status = _CaptureStatus.unavailable);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    try {
      final shot = await controller.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final rawPath = '${dir.path}/scans/raw_${DateTime.now().microsecondsSinceEpoch}.jpg';
      await File(rawPath).parent.create(recursive: true);
      await File(shot.path).copy(rawPath);

      if (!mounted) return;
      final cropped = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => CropScreen(imagePath: rawPath)),
      );
      if (cropped != null) {
        setState(() => _pages.add(cropped));
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  void _removePage(int index) => setState(() => _pages.removeAt(index));

  Future<void> _onDone() async {
    if (_pages.isEmpty || _finishing) return;
    final result = await showModalBottomSheet<({String title, DocumentCategory category})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NameAndCategorySheet(),
    );
    if (result == null) return;

    setState(() => _finishing = true);
    final ocrText = await OcrService.recognizePages(_pages);

    final now = DateTime.now();
    final doc = Document(
      id: now.millisecondsSinceEpoch,
      familyMemberId: widget.memberId,
      title: result.title,
      category: result.category,
      pagePaths: List.of(_pages),
      ocrText: ocrText.isEmpty ? null : ocrText,
      scannedDate: now,
      createdAt: now,
      updatedAt: now,
    );

    if (!mounted) return;
    ref.read(documentProvider(widget.memberId).notifier).addRecord(doc);
    context.pushReplacement(Routes.documentDetail(doc.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildPreview()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      ),
                      child: Text(
                        _pages.isEmpty ? 'Scan a document' : '${_pages.length} page${_pages.length == 1 ? '' : 's'}',
                        style: AppTypography.chip.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    switch (_status) {
      case _CaptureStatus.loading:
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      case _CaptureStatus.denied:
        return const _StatusMessage(
          icon: Icons.no_photography_outlined,
          message: 'Camera access was denied. Enable it in your device settings to scan documents.',
        );
      case _CaptureStatus.unavailable:
        return const _StatusMessage(
          icon: Icons.camera_alt_outlined,
          message: 'No camera is available on this device.',
        );
      case _CaptureStatus.ready:
        final controller = _controller!;
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 1,
            height: controller.value.previewSize?.width ?? 1,
            child: CameraPreview(controller),
          ),
        );
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_pages.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _PageThumb(path: _pages[i], onRemove: () => _removePage(i)),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 64,
                child: _pages.isEmpty
                    ? const SizedBox.shrink()
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusTileS)),
                        ),
                        onPressed: _finishing ? null : _onDone,
                        child: _finishing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Done'),
                      ),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _status == _CaptureStatus.ready ? _capture : null,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white38, width: 4),
                      ),
                      child: _capturing
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 64),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageThumb extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _PageThumb({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path), width: 44, height: 56, fit: BoxFit.cover),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  const _StatusMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.white54),
            const SizedBox(height: 14),
            Text(message, style: AppTypography.body.copyWith(color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NameAndCategorySheet extends StatefulWidget {
  const _NameAndCategorySheet();

  @override
  State<_NameAndCategorySheet> createState() => _NameAndCategorySheetState();
}

class _NameAndCategorySheetState extends State<_NameAndCategorySheet> {
  final _controller = TextEditingController();
  DocumentCategory _category = DocumentCategory.labReport;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name this document', style: AppTypography.detailTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'e.g. Lipid profile — Aug 2026',
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('CATEGORY', style: AppTypography.eyebrow),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in DocumentCategory.values)
                  _CategoryChip(
                    category: c,
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusTileS)),
                ),
                onPressed: () {
                  final title = _controller.text.trim().isEmpty ? _category.displayName : _controller.text.trim();
                  Navigator.of(context).pop((title: title, category: _category));
                },
                child: const Text('Read and save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final DocumentCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = DocumentColors.getHue(category);
    return Material(
      color: selected ? AppColors.tint(hue) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? hue : AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, size: 15, color: selected ? hue : AppColors.textMuted5),
              const SizedBox(width: 6),
              Text(category.displayName, style: AppTypography.chip.copyWith(color: selected ? hue : AppColors.textMuted5)),
            ],
          ),
        ),
      ),
    );
  }
}
