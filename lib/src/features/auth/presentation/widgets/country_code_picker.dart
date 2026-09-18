import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class CountryDialCode {
  const CountryDialCode({
    required this.name,
    required this.iso2,
    required this.dialCode,
    required this.flag,
  });

  final String name;
  final String iso2;
  final String dialCode;
  final String flag;

  String get searchHaystack =>
      '$name $iso2 $dialCode'.toLowerCase();
}

const kDefaultCountry = CountryDialCode(
  name: 'Germany',
  iso2: 'DE',
  dialCode: '+49',
  flag: '🇩🇪',
);

const kCountryDialCodes = <CountryDialCode>[
  kDefaultCountry,
  CountryDialCode(name: 'Austria', iso2: 'AT', dialCode: '+43', flag: '🇦🇹'),
  CountryDialCode(name: 'Switzerland', iso2: 'CH', dialCode: '+41', flag: '🇨🇭'),
  CountryDialCode(name: 'Netherlands', iso2: 'NL', dialCode: '+31', flag: '🇳🇱'),
  CountryDialCode(name: 'Belgium', iso2: 'BE', dialCode: '+32', flag: '🇧🇪'),
  CountryDialCode(name: 'France', iso2: 'FR', dialCode: '+33', flag: '🇫🇷'),
  CountryDialCode(name: 'Italy', iso2: 'IT', dialCode: '+39', flag: '🇮🇹'),
  CountryDialCode(name: 'Spain', iso2: 'ES', dialCode: '+34', flag: '🇪🇸'),
  CountryDialCode(name: 'Portugal', iso2: 'PT', dialCode: '+351', flag: '🇵🇹'),
  CountryDialCode(name: 'United Kingdom', iso2: 'GB', dialCode: '+44', flag: '🇬🇧'),
  CountryDialCode(name: 'Ireland', iso2: 'IE', dialCode: '+353', flag: '🇮🇪'),
  CountryDialCode(name: 'Poland', iso2: 'PL', dialCode: '+48', flag: '🇵🇱'),
  CountryDialCode(name: 'Czechia', iso2: 'CZ', dialCode: '+420', flag: '🇨🇿'),
  CountryDialCode(name: 'Sweden', iso2: 'SE', dialCode: '+46', flag: '🇸🇪'),
  CountryDialCode(name: 'Norway', iso2: 'NO', dialCode: '+47', flag: '🇳🇴'),
  CountryDialCode(name: 'Denmark', iso2: 'DK', dialCode: '+45', flag: '🇩🇰'),
  CountryDialCode(name: 'Finland', iso2: 'FI', dialCode: '+358', flag: '🇫🇮'),
  CountryDialCode(name: 'Greece', iso2: 'GR', dialCode: '+30', flag: '🇬🇷'),
  CountryDialCode(name: 'Hungary', iso2: 'HU', dialCode: '+36', flag: '🇭🇺'),
  CountryDialCode(name: 'Romania', iso2: 'RO', dialCode: '+40', flag: '🇷🇴'),
  CountryDialCode(name: 'Turkey', iso2: 'TR', dialCode: '+90', flag: '🇹🇷'),
  CountryDialCode(name: 'United States', iso2: 'US', dialCode: '+1', flag: '🇺🇸'),
  CountryDialCode(name: 'Canada', iso2: 'CA', dialCode: '+1', flag: '🇨🇦'),
  CountryDialCode(name: 'Australia', iso2: 'AU', dialCode: '+61', flag: '🇦🇺'),
  CountryDialCode(name: 'India', iso2: 'IN', dialCode: '+91', flag: '🇮🇳'),
  CountryDialCode(name: 'Pakistan', iso2: 'PK', dialCode: '+92', flag: '🇵🇰'),
  CountryDialCode(name: 'United Arab Emirates', iso2: 'AE', dialCode: '+971', flag: '🇦🇪'),
  CountryDialCode(name: 'Saudi Arabia', iso2: 'SA', dialCode: '+966', flag: '🇸🇦'),
  CountryDialCode(name: 'Brazil', iso2: 'BR', dialCode: '+55', flag: '🇧🇷'),
  CountryDialCode(name: 'Mexico', iso2: 'MX', dialCode: '+52', flag: '🇲🇽'),
  CountryDialCode(name: 'Japan', iso2: 'JP', dialCode: '+81', flag: '🇯🇵'),
  CountryDialCode(name: 'South Korea', iso2: 'KR', dialCode: '+82', flag: '🇰🇷'),
  CountryDialCode(name: 'China', iso2: 'CN', dialCode: '+86', flag: '🇨🇳'),
  CountryDialCode(name: 'Singapore', iso2: 'SG', dialCode: '+65', flag: '🇸🇬'),
  CountryDialCode(name: 'South Africa', iso2: 'ZA', dialCode: '+27', flag: '🇿🇦'),
  CountryDialCode(name: 'Nigeria', iso2: 'NG', dialCode: '+234', flag: '🇳🇬'),
  CountryDialCode(name: 'Egypt', iso2: 'EG', dialCode: '+20', flag: '🇪🇬'),
  CountryDialCode(name: 'Luxembourg', iso2: 'LU', dialCode: '+352', flag: '🇱🇺'),
  CountryDialCode(name: 'Croatia', iso2: 'HR', dialCode: '+385', flag: '🇭🇷'),
  CountryDialCode(name: 'Slovakia', iso2: 'SK', dialCode: '+421', flag: '🇸🇰'),
  CountryDialCode(name: 'Slovenia', iso2: 'SI', dialCode: '+386', flag: '🇸🇮'),
  CountryDialCode(name: 'Bulgaria', iso2: 'BG', dialCode: '+359', flag: '🇧🇬'),
  CountryDialCode(name: 'Ukraine', iso2: 'UA', dialCode: '+380', flag: '🇺🇦'),
  CountryDialCode(name: 'New Zealand', iso2: 'NZ', dialCode: '+64', flag: '🇳🇿'),
];

class CountryCodePicker extends StatelessWidget {
  const CountryCodePicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final CountryDialCode selected;
  final ValueChanged<CountryDialCode> onChanged;
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<CountryDialCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.bottomSheet,
      ),
      builder: (_) => _CountryPickerSheet(selected: selected),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return GestureDetector(
      onTap: enabled ? () => _openPicker(context) : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 8.w, 10.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 6.w),
            Text(
              selected.dialCode,
              style: tt.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18.sp,
              color: cs.onSurfaceVariant,
            ),
            SizedBox(width: 6.w),
            SizedBox(
              height: 22.h,
              child: VerticalDivider(
                width: 1,
                thickness: 1,
                color: cs.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selected});

  final CountryDialCode selected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  late List<CountryDialCode> _filtered = kCountryDialCodes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    final needle = query.trim().toLowerCase();
    setState(() {
      if (needle.isEmpty) {
        _filtered = kCountryDialCodes;
        return;
      }
      _filtered = kCountryDialCodes
          .where((country) => country.searchHaystack.contains(needle))
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: 0.72.sh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg.w,
                AppSpacing.xs.h,
                AppSpacing.lg.w,
                AppSpacing.md.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'auth.select_country'.tr(),
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  AppTextField(
                    controller: _searchController,
                    hint: 'auth.search_country'.tr(),
                    prefixIcon: const Icon(Icons.search_rounded),
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'auth.country_not_found'.tr(),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: cs.outline.withValues(alpha: 0.35),
                      ),
                      itemBuilder: (context, index) {
                        final country = _filtered[index];
                        final isSelected =
                            country.iso2 == widget.selected.iso2 &&
                                country.dialCode == widget.selected.dialCode;
                        return ListTile(
                          leading: Text(
                            country.flag,
                            style: TextStyle(fontSize: 22.sp),
                          ),
                          title: Text(country.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country.dialCode,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(width: AppSpacing.sm.w),
                                Icon(
                                  Icons.check_rounded,
                                  color: cs.primary,
                                  size: 20.sp,
                                ),
                              ],
                            ],
                          ),
                          onTap: () => Navigator.of(context).pop(country),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
