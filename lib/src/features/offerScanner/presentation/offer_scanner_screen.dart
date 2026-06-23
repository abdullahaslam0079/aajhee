import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class OfferScannerScreen extends StatefulWidget {
  const OfferScannerScreen({super.key});

  @override
  State<OfferScannerScreen> createState() => _OfferScannerScreenState();
}

class _OfferScannerScreenState extends State<OfferScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _hasHandledScan = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.hasCameraPermission) return;
    if (state == AppLifecycleState.resumed) {
      _scannerController.start();
      return;
    }
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _scannerController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasHandledScan) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _hasHandledScan = true;
      _lastScannedCode = code;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code scanned successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.65);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primary.withValues(alpha: 0.12),
                  cs.surface,
                  cs.surface,
                ],
                stops: const [0, 0.28, 1],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.sm.h),
                  _header(cs, tt),
                  SizedBox(height: AppSpacing.xl.h),
                  Expanded(
                    child: Center(
                      child: _scannerCard(cs, tt, muted),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    _lastScannedCode == null
                        ? 'Align the QR code inside the frame'
                        : 'Code: $_lastScannedCode',
                    style: tt.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    _lastScannedCode == null ? 'Scanning starts automatically' : 'Scan complete',
                    style: tt.labelLarge?.copyWith(
                      color: _lastScannedCode == null ? cs.primary : Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ColorScheme cs, TextTheme tt) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(
            backgroundColor: cs.onPrimary,
            foregroundColor: cs.onSurface,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: AppSpacing.xs.h,
            ),
            decoration: BoxDecoration(
              color: cs.onPrimary,
              borderRadius: AppBorders.full,
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: AppBorders.full,
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: cs.primary,
                    size: 18,
                  ),
                ),
                SizedBox(width: AppSpacing.xs.w),
                Text(
                  'Goluto',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppSpacing.xs.w),
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: _scannerController,
          builder: (context, state, child) {
            return IconButton.filledTonal(
              onPressed: () => _scannerController.toggleTorch(),
              style: IconButton.styleFrom(
                backgroundColor: cs.onPrimary,
                foregroundColor: cs.primary,
              ),
              icon: Icon(
                state.torchState == TorchState.on
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _scannerCard(ColorScheme cs, TextTheme tt, Color muted) {
    return Container(
      width: 305.w,
      padding: EdgeInsets.all(AppSpacing.ms.r),
      decoration: BoxDecoration(
        color: cs.onPrimary,
        borderRadius: AppBorders.lg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scan Offer Code',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Container(
            width: 232.w,
            height: 232.w,
            padding: EdgeInsets.all(AppSpacing.xs.r),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppBorders.md,
              border: Border.all(color: cs.primary.withValues(alpha: 0.45)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: AppBorders.sm,
                  child: MobileScanner(
                    controller: _scannerController,
                    fit: BoxFit.cover,
                    onDetect: _onDetect,
                  ),
                ),
                if (_lastScannedCode == null)
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: cs.primary.withValues(alpha: 0.55),
                      size: 74,
                    ),
                  ),
                if (_lastScannedCode != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: AppBorders.sm,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: Colors.white, size: 40),
                        SizedBox(height: AppSpacing.xxs.h),
                        Text(
                          'Scanned',
                          style: tt.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _hasHandledScan = false;
                              _lastScannedCode = null;
                            });
                          },
                          child: Text(
                            'Scan Again',
                            style: tt.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  left: 10.w,
                  top: 10.h,
                  child: _scannerCorner(cs),
                ),
                Positioned(
                  right: 10.w,
                  top: 10.h,
                  child: Transform.rotate(
                    angle: 1.57,
                    child: _scannerCorner(cs),
                  ),
                ),
                Positioned(
                  left: 10.w,
                  bottom: 10.h,
                  child: Transform.rotate(
                    angle: -1.57,
                    child: _scannerCorner(cs),
                  ),
                ),
                Positioned(
                  right: 10.w,
                  bottom: 10.h,
                  child: Transform.rotate(
                    angle: 3.14,
                    child: _scannerCorner(cs),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.xs.h,
              horizontal: AppSpacing.sm.w,
            ),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: AppBorders.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Icon(Icons.security_rounded, size: 16, color: cs.primary),
                SizedBox(width: AppSpacing.xxs.w),
                Text(
                  'Secure checkout scan',
                  style: tt.labelLarge?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scannerCorner(ColorScheme cs) {
    return SizedBox(
      width: 26.w,
      height: 26.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: cs.primary, width: 3),
            top: BorderSide(color: cs.primary, width: 3),
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8.r)),
        ),
      ),
    );
  }
}