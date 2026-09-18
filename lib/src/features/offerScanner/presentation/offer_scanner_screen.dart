import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/branch_offers_provider.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_scanner_session.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_usage_status.dart';
import 'package:aajhee/src/features/offerScanner/presentation/providers/offer_redemption_provider.dart';
import 'package:aajhee/src/features/offerScanner/presentation/providers/offer_usage_status_provider.dart';
import 'package:aajhee/src/features/offerScanner/presentation/widgets/offer_counter_confirmation_sheet.dart';
import 'package:aajhee/src/features/offerScanner/presentation/widgets/offer_redemption_success_dialog.dart';
import 'package:aajhee/src/features/offerScanner/presentation/widgets/offer_usage_status_banner.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class OfferScannerScreen extends ConsumerStatefulWidget {
  const OfferScannerScreen({
    super.key,
    this.offer,
    this.branchId,
    this.navigateToBranchOnSuccess = false,
  });

  final OfferModel? offer;
  final int? branchId;
  final bool navigateToBranchOnSuccess;

  @override
  ConsumerState<OfferScannerScreen> createState() => _OfferScannerScreenState();
}

class _OfferScannerScreenState extends ConsumerState<OfferScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _hasHandledScan = false;
  bool _confirmationSheetOpen = false;

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
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _scannerController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  OfferScannerSession get _session => OfferScannerSession(
        offer: widget.offer,
        branchId: widget.branchId,
        navigateToBranchOnSuccess: widget.navigateToBranchOnSuccess,
      );

  OfferRedemptionState get _redemptionState =>
      ref.watch(offerRedemptionProvider(_session));

  OfferRedemption get _redemptionNotifier =>
      ref.read(offerRedemptionProvider(_session).notifier);

  void _onDetect(BarcodeCapture capture) {
    if (_hasHandledScan || _redemptionState.isBusy || _confirmationSheetOpen) {
      return;
    }
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    final selectedOffer = _redemptionState.selectedOffer ?? widget.offer;
    if (selectedOffer != null) {
      final usageStatus = ref.read(offerUsageStatusProvider(selectedOffer));
      if (!usageStatus.isAvailable) {
        showToast(
          context,
          message: usageStatus.availabilityLabel,
          status: 'warning',
        );
        return;
      }
    }

    setState(() => _hasHandledScan = true);
    _resolveCode(code);
  }

  Future<void> _resolveCode(String code) async {
    await _redemptionNotifier.resolveScannedCode(code);
    if (!mounted) return;

    final state = ref.read(offerRedemptionProvider(_session));
    if (state.needsBillAmount || state.needsConfirmation) {
      await _scannerController.stop();
      await _showConfirmationSheet(state);
      return;
    }

    await _handleTerminalState(state);
  }

  Future<void> _showConfirmationSheet(OfferRedemptionState state) async {
    final offer = state.selectedOffer;
    final payment = state.paymentPreview;
    if (offer == null || payment == null) return;

    setState(() => _confirmationSheetOpen = true);

    await OfferCounterConfirmationSheet.show(
      context,
      offer: offer,
      branchName: state.branchName ?? 'Branch',
      branchAddress: state.branchAddress ?? '',
      payment: payment,
      needsBillAmount: state.needsBillAmount,
      isProcessing: state.isBusy,
      errorMessage: state.errorMessage,
      onBillAmountSubmit: (amount) async {
        await _redemptionNotifier.submitBillAmount(amount);
        if (!mounted) return;
        final updated = ref.read(offerRedemptionProvider(_session));
        if (updated.needsConfirmation && updated.paymentPreview != null) {
          Navigator.of(context).pop();
          setState(() => _confirmationSheetOpen = false);
          await _showConfirmationSheet(updated);
        }
      },
      onConfirm: () async {
        await _redemptionNotifier.confirmAvail();
        if (!mounted) return;
        Navigator.of(context).pop();
        setState(() => _confirmationSheetOpen = false);
        final updated = ref.read(offerRedemptionProvider(_session));
        await _handleTerminalState(updated);
      },
    );

    if (mounted) {
      setState(() => _confirmationSheetOpen = false);
      final current = ref.read(offerRedemptionProvider(_session));
      if (current.status == OfferRedemptionStatus.idle ||
          current.status == OfferRedemptionStatus.error) {
        setState(() => _hasHandledScan = false);
        if (!_scannerController.value.isRunning) {
          await _scannerController.start();
        }
      }
    }
  }

  Future<void> _handleTerminalState(OfferRedemptionState state) async {
    if (state.status == OfferRedemptionStatus.redeemed &&
        state.redeemedOffer != null) {
      await _scannerController.stop();
      if (!mounted) return;

      final redeemedOffer = state.redeemedOffer!;
      final usageStatus = state.usageStatus ??
          OfferUsageStatus.fromOffer(redeemedOffer);

      await OfferRedemptionSuccessDialog.show(
        context,
        offer: redeemedOffer,
        usageStatus: usageStatus,
        paymentPreview: state.paymentPreview,
      );

      if (!mounted) return;
      final branchId = state.branchId ?? widget.branchId ?? _session.branchId;
      if (branchId != null) {
        ref.invalidate(branchOffersProvider(branchId));
      }

      if (widget.navigateToBranchOnSuccess && branchId != null) {
        final branch = await _resolveBranch(branchId);
        if (!mounted) return;
        context.pop();
        if (branch != null) {
          context.push(AppRoutes.businessStore, extra: branch);
        }
        return;
      }

      context.pop();
      return;
    }

    if (state.status == OfferRedemptionStatus.error &&
        state.errorMessage != null) {
      showToast(context, message: state.errorMessage!, status: 'error');
      setState(() => _hasHandledScan = false);
    }
  }

  Future<MapBranchModel?> _resolveBranch(int branchId) async {
    final cachedBranches = ref.read(homeFeedProvider).branches;
    for (final branch in cachedBranches) {
      if (branch.id == branchId) return branch;
    }

    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final result = await ref.read(discoveryServiceProvider).findBranchById(
          branchId,
          addressId: addressId,
        );
    return result.fold((_) => null, (branch) => branch);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.65);
    final redemption = _redemptionState;
    final isProcessing = redemption.isBusy;
    final selectedOffer = redemption.selectedOffer ?? widget.offer;
    final usageStatus =
        selectedOffer != null ? ref.watch(offerUsageStatusProvider(selectedOffer)) : null;

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
                  if (usageStatus != null) ...[
                    SizedBox(height: AppSpacing.md.h),
                    OfferUsageStatusBanner(status: usageStatus),
                  ],
                  SizedBox(height: AppSpacing.xl.h),
                  Expanded(
                    child: Center(
                      child: _scannerCard(
                        cs,
                        tt,
                        muted,
                        isProcessing: isProcessing,
                        selectedOffer: selectedOffer,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    _statusHeadline(
                      isProcessing: isProcessing,
                      selectedOffer: selectedOffer,
                    ),
                    style: tt.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    _statusSubline(
                      isProcessing: isProcessing,
                      hasSelectedOffer: selectedOffer != null,
                    ),
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
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

  String _statusHeadline({
    required bool isProcessing,
    required OfferModel? selectedOffer,
  }) {
    if (isProcessing) return 'Processing your offer...';
    if (selectedOffer != null) {
      return 'Scan the poster QR for "${selectedOffer.title}"';
    }
    return 'Point your camera at the store poster QR';
  }

  String _statusSubline({
    required bool isProcessing,
    required bool hasSelectedOffer,
  }) {
    if (isProcessing) return 'Please wait';
    if (hasSelectedOffer) {
      return 'You will see what to pay before availing';
    }
    return 'Payment amount appears on your phone';
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
                  'Aajhee',
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

  Widget _scannerCard(
    ColorScheme cs,
    TextTheme tt,
    Color muted, {
    required bool isProcessing,
    required OfferModel? selectedOffer,
  }) {
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
            selectedOffer?.title ?? 'Scan Poster QR',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          if (selectedOffer != null) ...[
            SizedBox(height: AppSpacing.xxs.h),
            Text(
              selectedOffer.businessName,
              style: tt.bodySmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
                if (!isProcessing)
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: cs.primary.withValues(alpha: 0.55),
                      size: 74,
                    ),
                  ),
                if (isProcessing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: AppBorders.sm,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: AppSpacing.sm.h),
                        Text(
                          'Loading offer...',
                          style: tt.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
                Icon(Icons.payments_outlined, size: 16, color: cs.primary),
                SizedBox(width: AppSpacing.xxs.w),
                Text(
                  'Amount to pay shown before availing',
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
