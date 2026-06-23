import 'package:goluto/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _initialized = false;
  bool _isSaving = false;

  void _initializeFields(UserProfileState profileState) {
    if (_initialized || profileState.isLoading) return;

    final profile = profileState.profile;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    _initialized = true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(userProfileProvider.notifier).updateProfile(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
          );

      if (!mounted) return;
      showToast(context, message: 'Profile updated', status: 'success');
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showToast(
        context,
        message: 'Could not save profile. Please try again.',
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
                        'Update your name and email address.',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      AppTextField(
                        controller: _firstNameController,
                        enabled: !_isSaving,
                        label: 'First name',
                        hint: 'e.g. Alex',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            AppUtils.isBlank(v) ? 'First name is required' : null,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _lastNameController,
                        enabled: !_isSaving,
                        label: 'Last name',
                        hint: 'e.g. Morgan',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            AppUtils.isBlank(v) ? 'Last name is required' : null,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _emailController,
                        enabled: !_isSaving,
                        label: 'Email address',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'Email is required';
                          }
                          if (!AppUtils.isValidEmail(v!)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
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
