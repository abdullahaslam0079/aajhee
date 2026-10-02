part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _PaymentProofNoteDialogState extends State<_PaymentProofNoteDialog> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Payment receipt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.fileName, style: tt.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Transaction reference / note (optional)',
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _noteController.text),
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
