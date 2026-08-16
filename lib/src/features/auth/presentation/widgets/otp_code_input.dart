import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
    this.autofocus = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool hasError;
  final bool autofocus;

  @override
  State<OtpCodeInput> createState() => OtpCodeInputState();
}

class OtpCodeInputState extends State<OtpCodeInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _lastEmitted = '';

  String get code => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _controller.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleChanged)
      ..dispose();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _handleChanged() {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > widget.length
        ? digits.substring(0, widget.length)
        : digits;
    if (clipped != _controller.text) {
      _controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
      return;
    }
    if (!mounted) return;
    setState(() {});
    if (_lastEmitted == clipped) return;
    _lastEmitted = clipped;
    widget.onChanged(clipped);
    if (clipped.length == widget.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller.text == clipped) {
          widget.onCompleted?.call(clipped);
        }
      });
    }
  }

  void clear() {
    _lastEmitted = '';
    _controller.clear();
    _focusNode.requestFocus();
  }

  void focus() => _focusNode.requestFocus();

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final code = _controller.text;
    final activeIndex = code.length.clamp(0, widget.length - 1);

    return SizedBox(
      height: 56.h,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              child: AutofillGroup(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  showCursor: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                  cursorColor: Colors.transparent,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    counterText: '',
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Row(
              children: List.generate(widget.length, (index) {
                final filled = index < code.length;
                final isActive = widget.enabled &&
                    _focusNode.hasFocus &&
                    index == activeIndex &&
                    code.length < widget.length;
                final borderColor = widget.hasError
                    ? cs.error
                    : isActive
                        ? cs.primary
                        : filled
                            ? cs.onSurface
                            : cs.outline;

                return Expanded(
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: AppBorders.input,
                      border: Border.all(
                        color: borderColor,
                        width: isActive || widget.hasError ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      filled ? code[index] : '',
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
