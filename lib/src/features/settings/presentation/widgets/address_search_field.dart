import 'dart:async';

import 'package:goluto/src/features/settings/data/services/address_autocomplete_service.dart';
import 'package:goluto/src/features/settings/domain/entities/address_suggestion.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class AddressSearchField extends StatefulWidget {
  const AddressSearchField({
    super.key,
    required this.onSuggestionSelected,
    this.enabled = true,
  });

  final ValueChanged<AddressSuggestion> onSuggestionSelected;
  final bool enabled;

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _autocompleteService = AddressAutocompleteService();

  Timer? _debounce;
  List<AddressSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _isResolving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() => _suggestions = []);
    }
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().length < 3) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isSearching = false;
            _errorMessage = null;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isSearching = true;
          _errorMessage = null;
        });
      }

      try {
        final results = await _autocompleteService.search(value);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _isSearching = false;
          _errorMessage = 'Could not load suggestions. Try again.';
        });
      }
    });
  }

  Future<void> _selectSuggestion(AddressSuggestion suggestion) async {
    setState(() {
      _isResolving = true;
      _suggestions = [];
      _errorMessage = null;
    });

    try {
      final resolved = await _autocompleteService.resolveSuggestion(suggestion);
      if (!mounted) return;

      _controller.text = resolved.shortLabel;
      _focusNode.unfocus();
      widget.onSuggestionSelected(resolved);

      setState(() => _isResolving = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResolving = false;
        _errorMessage = 'Could not load address details. Try another result.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final showSuggestions = _focusNode.hasFocus && _suggestions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled && !_isResolving,
          label: 'Search address',
          hint: 'Start typing your address...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _isSearching || _isResolving
              ? Padding(
                  padding: EdgeInsets.all(12.r),
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                )
              : _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: widget.enabled
                          ? () {
                              _controller.clear();
                              setState(() {
                                _suggestions = [];
                                _errorMessage = null;
                              });
                            }
                          : null,
                    )
                  : null,
          onChanged: _onQueryChanged,
          textInputAction: TextInputAction.search,
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: AppSpacing.xs.h),
          Text(
            _errorMessage!,
            style: tt.bodySmall?.copyWith(color: cs.error),
          ),
        ],
        if (showSuggestions) ...[
          SizedBox(height: AppSpacing.xs.h),
          Material(
            elevation: 0,
            color: cs.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.lg,
              side: BorderSide(color: cs.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: cs.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: cs.secondary,
                  ),
                  title: Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: suggestion.subtitle != null
                      ? Text(
                          suggestion.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        )
                      : null,
                  onTap: widget.enabled
                      ? () => _selectSuggestion(suggestion)
                      : null,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
