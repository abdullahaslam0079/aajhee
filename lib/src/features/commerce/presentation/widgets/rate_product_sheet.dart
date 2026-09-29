import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_borders.dart';
import '../../data/commerce_api_service.dart';

/// Bottom sheet for rating a delivered order line item (stars + text + photos).
Future<bool> showRateProductSheet({
  required BuildContext context,
  required CommerceApiService api,
  required String orderPublicId,
  required Map<String, dynamic> item,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => _RateProductSheet(
      api: api,
      orderPublicId: orderPublicId,
      item: item,
    ),
  );
  return result == true;
}

class _RateProductSheet extends StatefulWidget {
  const _RateProductSheet({
    required this.api,
    required this.orderPublicId,
    required this.item,
  });

  final CommerceApiService api;
  final String orderPublicId;
  final Map<String, dynamic> item;

  @override
  State<_RateProductSheet> createState() => _RateProductSheetState();
}

class _RateProductSheetState extends State<_RateProductSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  final List<XFile> _photos = [];
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_photos.length >= 5) return;
    final remaining = 5 - _photos.length;
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 2000,
      limit: remaining,
    );
    if (!mounted || picked.isEmpty) return;
    setState(() {
      _photos.addAll(picked.take(remaining));
    });
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      setState(() => _error = 'Please select a star rating.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final itemId = widget.item['id'];
    if (itemId == null) {
      setState(() {
        _submitting = false;
        _error = 'Missing order item.';
      });
      return;
    }
    final files = <MultipartFile>[];
    for (final photo in _photos) {
      files.add(
        await MultipartFile.fromFile(
          photo.path,
          filename: photo.name.isNotEmpty
              ? photo.name
              : photo.path.split(Platform.pathSeparator).last,
        ),
      );
    }
    final result = await widget.api.createOrderItemReview(
      publicId: widget.orderPublicId,
      itemId: itemId is int ? itemId : int.parse('$itemId'),
      rating: _rating,
      comment: _commentCtrl.text.trim(),
      images: files,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _submitting = false;
          _error = failure.message;
        });
      },
      (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = (widget.item['product_name']?.toString().trim().isNotEmpty ??
            false)
        ? widget.item['product_name'].toString()
        : 'Product';
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: AppBorders.full,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Rate your purchase',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4.h),
            Text(
              name,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                final filled = star <= _rating;
                return IconButton(
                  onPressed: _submitting
                      ? null
                      : () => setState(() => _rating = star),
                  icon: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? const Color(0xFFE6A817) : cs.outline,
                    size: 36.sp,
                  ),
                );
              }),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              maxLength: 1000,
              enabled: !_submitting,
              decoration: InputDecoration(
                hintText: 'Share details (optional)',
                border: OutlineInputBorder(borderRadius: AppBorders.md),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                ..._photos.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: AppBorders.md,
                        child: Image.file(
                          File(entry.value.path),
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: _submitting
                              ? null
                              : () => setState(
                                    () => _photos.removeAt(entry.key),
                                  ),
                          child: CircleAvatar(
                            radius: 10.r,
                            backgroundColor: cs.error,
                            child: Icon(
                              Icons.close,
                              size: 12.sp,
                              color: cs.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                if (_photos.length < 5)
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _pickPhotos,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text('Photos (${_photos.length}/5)'),
                  ),
              ],
            ),
            if (_error != null) ...[
              SizedBox(height: 10.h),
              Text(
                _error!,
                style: tt.bodySmall?.copyWith(color: cs.error),
              ),
            ],
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit review'),
            ),
          ],
        ),
      ),
    );
  }
}
