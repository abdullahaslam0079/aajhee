part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

mixin OrderDetailScreenController
    on
        WidgetsBindingObserver,
        PeriodicRefreshMixin<OrderDetailScreen>,
        ConsumerState<OrderDetailScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  OrderDetail? _order;
  final Map<int, String> _productImages = {};
  bool _loading = true;
  bool _cancelling = false;
  bool _reporting = false;
  int _lastRealtimeTick = 0;

  static const _terminalStatuses = {
    'completed',
    'cancelled',
  };

  @override
  Duration get refreshInterval => const Duration(seconds: 20);

  @override
  bool get shouldPeriodicRefresh {
    final status = _order?.status.toLowerCase();
    if (status == null || status.isEmpty) return true;
    return !_terminalStatuses.contains(status);
  }

  @override
  void initState() {
    super.initState();
    _load();
    startPeriodicRefresh();
  }

  @override
  void dispose() {
    stopPeriodicRefresh();
    super.dispose();
  }

  @override
  Future<void> onPeriodicRefresh() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }
    final result = await _api.getOrder(widget.publicId);
    if (!mounted) return;
    await result.fold(
      (f) async {
        if (silent) return;
        setState(() {
          _loading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        });
      },
      (order) async {
        setState(() {
          _order = order;
          _loading = false;
        });
        await _loadProductImages(order);
      },
    );
  }

  Future<void> _loadProductImages(OrderDetail order) async {
    final pendingIds = <int>{};
    for (final item in order.lines) {
      final embedded = item.imageUrl;
      final productId = item.productId;
      if (embedded != null && productId != null) {
        _productImages[productId] = embedded;
        continue;
      }
      if (productId != null && !_productImages.containsKey(productId)) {
        pendingIds.add(productId);
      }
    }
    if (pendingIds.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    await Future.wait(pendingIds.map((id) async {
      final result = await _api.getProduct(id);
      result.fold((_) {}, (product) {
        final url = product['image_url']?.toString().trim();
        if (url != null && url.isNotEmpty) {
          _productImages[id] = url;
        }
      });
    }));
    if (mounted) setState(() {});
  }

  Future<void> _cancelOrder() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel order?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You can only cancel while the shop has not accepted yet.',
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: reasonController,
                  autofocus: true,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Why are you cancelling?',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep order'),
            ),
            FilledButton(
              onPressed: () {
                final text = reasonController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Cancel order'),
            ),
          ],
        );
      },
    );
    reasonController.dispose();
    if (reason == null || reason.isEmpty) return;

    setState(() => _cancelling = true);
    final result = await _api.cancelOrder(
      widget.publicId,
      reason: reason,
    );
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
      (_) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
        _load();
      },
    );
  }

  Future<void> _contactStore() async {
    final order = _order;
    if (order == null) return;
    final raw = order.storeContact;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No store contact available')),
      );
      return;
    }
    final result = await UrlLauncherService.instance.launch(digits);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {},
    );
  }

  Future<void> _reportProblem() async {
    final messageController = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Report a problem'),
          content: TextField(
            controller: messageController,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'What went wrong?',
              hintText: 'Describe the issue',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = messageController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    messageController.dispose();
    if (message == null || message.isEmpty) return;

    setState(() => _reporting = true);
    final result = await _api.reportOrderProblem(
      publicId: widget.publicId,
      message: message,
    );
    if (!mounted) return;
    setState(() => _reporting = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem reported')),
      ),
    );
  }

  Future<void> _uploadProof() async {
    final colors = Theme.of(context).colorScheme;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final labelStyle =
            Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: colors.onSurface,
                ),
                title: Text('Choose from gallery', style: labelStyle),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera_outlined,
                  color: colors.onSurface,
                ),
                title: Text('Take a photo', style: labelStyle),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !mounted) return;

    // Let the sheet finish dismissing before presenting the native picker.
    // Calling pickImage mid-transition often fails on iOS with a channel-error.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    late final XFile picked;
    try {
      final result = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        requestFullMetadata: false,
      );
      if (result == null || !mounted) return;
      picked = result;
    } on PlatformException catch (e) {
      if (!mounted) return;
      final needsRebuild = e.code == 'channel-error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            needsRebuild
                ? 'Photo picker needs a full app restart. Stop the app and run again.'
                : (e.message ?? 'Could not open the photo picker.'),
          ),
        ),
      );
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the photo picker.')),
      );
      return;
    }

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _PaymentProofNoteDialog(
        fileName: picked.name,
      ),
    );
    if (note == null || !mounted) return;

    final result = await _api.uploadPaymentProof(
      publicId: widget.publicId,
      file: UploadFile(path: picked.path, filename: picked.name),
      note: note,
    );
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment proof submitted')),
        );
        _load();
      },
    );
  }

  bool _hasFee(String fee) {
    if (fee.isEmpty) return false;
    final parsed = double.tryParse(fee);
    return parsed == null ? true : parsed > 0;
  }

  String _pendingCancelBlockedReason(OrderDetail order) {
    if (order.customerCancelAllowed == false) {
      return 'This shop does not allow customers to cancel orders. '
          'Contact the shop if you need help.';
    }
    final until = DateTime.tryParse(order.customerCancelUntil);
    if (until != null && DateTime.now().isAfter(until)) {
      return 'The cancellation window closed at '
          '${formatCommerceDateTime(order.customerCancelUntil)}. '
          'Contact the shop if you need help.';
    }
    return 'This order can no longer be cancelled. '
        'Contact the shop if you need help.';
  }
}
