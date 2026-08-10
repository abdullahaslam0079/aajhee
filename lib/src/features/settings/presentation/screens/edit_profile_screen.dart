import 'package:goluto/src/features/settings/domain/entities/user_profile.dart';
import 'package:goluto/src/features/settings/presentation/providers/user_profile_provider.dart'
    hide UserProfile;
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSaving = false;
  String? _seedKey;

  void _syncFields(UserProfile profile) {
    final seedKey = '${profile.name}|${profile.phone}|${profile.email}';
    if (_seedKey == seedKey) return;

    _nameController.text = profile.name;
    _phoneController.text = profile.phone ?? '';
    _seedKey = seedKey;
  }

  void _initializeFields(UserProfileState profileState) {
    if (profileState.isLoading || _isSaving) return;
    _syncFields(profileState.profile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(userProfileProvider.notifier).updateProfile(
            name: _nameController.text,
          );

      if (!mounted) return;
      showToast(context, message: 'Profile updated', status: 'success');
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final message = error is Exception
          ? error.toString().replaceFirst('Exception: ', '')
          : 'Could not save profile. Please try again.';
      showToast(
        context,
        message: message.isNotEmpty
            ? message
            : 'Could not save profile. Please try again.',
        status: 'error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final pagePadding = AppSpacing.pagePadding.w;
    final profileState = ref.watch(userProfileProvider);

    _initializeFields(profileState);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Edit profile'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: profileState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  pagePadding,
                  AppSpacing.md.h,
                  pagePadding,
                  AppSpacing.xl.h,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Personal information',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        'Update your name. Phone number cannot be changed here.',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      AppTextField(
                        controller: _nameController,
                        enabled: !_isSaving,
                        label: 'Full name',
                        hint: 'e.g. Alex Morgan',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!_isSaving) _saveProfile();
                        },
                        validator: (v) =>
                            AppUtils.isBlank(v) ? 'Name is required' : null,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _phoneController,
                        enabled: false,
                        readOnly: true,
                        label: 'Phone number',
                        hint: '+49 …',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      AppButton(
                        label: 'Save changes',
                        isLoading: _isSaving,
                        onPressed: _isSaving ? null : _saveProfile,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
