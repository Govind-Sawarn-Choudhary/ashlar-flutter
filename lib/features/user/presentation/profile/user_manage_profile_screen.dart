import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_messenger.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_auth_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';

/// Manage profile — view details first, then edit on demand.
class UserManageProfileScreen extends StatefulWidget {
  const UserManageProfileScreen({super.key});

  @override
  State<UserManageProfileScreen> createState() => _UserManageProfileScreenState();
}

class _UserManageProfileScreenState extends State<UserManageProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _languageController = TextEditingController();

  UserProfileSnapshot? _profile;
  String? _phone;
  bool _loading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _wasUpdated = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _applyToControllers(UserProfileSnapshot profile) {
    _fullNameController.text = profile.fullName ?? '';
    _locationController.text = profile.location ?? '';
    _emailController.text = profile.email ?? '';
    _languageController.text = profile.language ?? 'English';
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final response = await UserRepository.instance.getMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = response.profile;
        _phone = response.phone;
        _applyToControllers(response.profile);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'Could not load profile';
          _loading = false;
        });
      }
    }
  }

  void _startEditing() {
    if (_profile != null) {
      _applyToControllers(_profile!);
    }
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    if (_profile != null) {
      _applyToControllers(_profile!);
    }
    setState(() => _isEditing = false);
  }

  Future<void> _pickLanguage() async {
    FocusScope.of(context).unfocus();
    final selected = await showUserLanguagePicker(
      context,
      selected: _languageController.text.trim().isEmpty
          ? null
          : _languageController.text.trim(),
    );
    if (selected != null && mounted) {
      setState(() => _languageController.text = selected);
    }
  }

  String? _firstValidationError() {
    return validateRequired(_fullNameController.text, 'full name') ??
        validateRequired(_locationController.text, 'location') ??
        validateEmail(_emailController.text) ??
        validateRequired(_languageController.text, 'preferred language');
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();

    final formValid = _formKey.currentState?.validate() ?? false;
    final manualError = _firstValidationError();
    if (!formValid || manualError != null) {
      AppMessenger.show(
        context,
        manualError ?? 'Please fix the highlighted fields',
        type: AppMessageType.error,
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final response = await UserRepository.instance.saveProfile(
        fullName: _fullNameController.text.trim(),
        location: _locationController.text.trim(),
        email: _emailController.text.trim(),
        language: _languageController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = response.profile;
        _wasUpdated = true;
        _isEditing = false;
        _isSaving = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppMessenger.show(context, e.message, type: AppMessageType.error);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppMessenger.show(
          context,
          'Could not save profile. Check your connection.',
          type: AppMessageType.error,
        );
      }
    }
  }

  void _onBack() {
    Navigator.of(context).pop(_wasUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final scale = FigmaScale.fromViewport(MediaQuery.sizeOf(context));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_isEditing) {
            _cancelEditing();
          } else {
            _onBack();
          }
        }
      },
      child: UserPremiumScaffold(
        appBar: UserPremiumAppBar(
          title: _isEditing ? 'Edit profile' : 'Manage profile',
          subtitle: _isEditing ? 'Update your details' : 'Your account information',
          leading: IconButton(
            onPressed: () {
              if (_isEditing) {
                _cancelEditing();
              } else {
                _onBack();
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: UserDesignTokens.textPrimary, size: 20),
          ),
          actions: [
            if (!_loading && _loadError == null && !_isEditing)
              TextButton.icon(
                onPressed: _startEditing,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Edit',
                  style: AppTypography.inter(
                    fontWeight: FontWeight.w700,
                    color: UserDesignTokens.gold,
                  ),
                ),
              ),
          ],
        ),
        bottomBar: _isEditing && !_loading && _loadError == null
            ? UserPremiumBottomBar(
                primaryLabel: 'Save changes',
                onPrimary: _onSave,
                secondaryLabel: 'Cancel',
                onSecondary: _cancelEditing,
                loading: _isSaving,
              )
            : null,
        body: _buildBody(scale),
      ),
    );
  }

  Widget _buildBody(FigmaScale scale) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: UserDesignTokens.gold),
      );
    }

    if (_loadError != null) {
      return UserEmptyState(
        icon: Icons.person_outline,
        title: 'Could not load profile',
        subtitle: _loadError!,
        actionLabel: 'Retry',
        onAction: _loadProfile,
      );
    }

    if (_isEditing) {
      return _buildEditForm();
    }

    return _buildProfileView();
  }

  Widget _buildProfileView() {
    final profile = _profile!;
    final name = profile.fullName?.trim().isNotEmpty == true
        ? profile.fullName!.trim()
        : 'User';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: UserDesignTokens.goldAccentCard(),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: UserDesignTokens.goldGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: UserDesignTokens.cardShadow,
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: AppTypography.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: UserDesignTokens.textPrimary,
                ),
              ),
              if (_phone?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Text(
                  '+91 $_phone',
                  style: AppTypography.inter(
                    fontSize: 14,
                    color: UserDesignTokens.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        UserSectionHeader(title: 'Personal details'),
        _ProfileDetailRow(
          icon: Icons.person_outline,
          label: 'Full name',
          value: profile.fullName,
        ),
        _ProfileDetailRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: profile.email,
        ),
        _ProfileDetailRow(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: profile.location,
        ),
        _ProfileDetailRow(
          icon: Icons.translate_rounded,
          label: 'Preferred language',
          value: profile.language,
        ),
        const SizedBox(height: 28),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: UserDesignTokens.goldGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: UserDesignTokens.gold.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _startEditing,
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_outlined, size: 20, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'Edit profile',
                      style: AppTypography.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    final name = _fullNameController.text.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Form(
      key: _formKey,
      child: ListView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: UserDesignTokens.goldAccentCard(),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: UserDesignTokens.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: UserDesignTokens.cardShadow,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: AppTypography.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal details',
                              style: AppTypography.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: UserDesignTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Keep your profile up to date for smoother bookings.',
                              style: AppTypography.inter(
                                fontSize: 12,
                                height: 1.35,
                                color: UserDesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                UserPremiumFormField(
                  label: 'Full name',
                  icon: Icons.person_outline_rounded,
                  controller: _fullNameController,
                  hint: 'Enter your full name',
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateRequired(v, 'full name'),
                ),
                const SizedBox(height: 20),
                UserPremiumFormField(
                  label: 'City / location',
                  icon: Icons.location_on_outlined,
                  controller: _locationController,
                  hint: 'Where are you based?',
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateRequired(v, 'location'),
                ),
                const SizedBox(height: 20),
                UserPremiumFormField(
                  label: 'Email address',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),
                const SizedBox(height: 20),
                UserPremiumFormField(
                  label: 'Preferred language',
                  icon: Icons.translate_rounded,
                  controller: _languageController,
                  hint: 'Select language',
                  readOnly: true,
                  onTap: _pickLanguage,
                  validator: (v) => validateRequired(v, 'preferred language'),
                  suffix: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: UserDesignTokens.gold,
                    size: 22,
                  ),
                ),
                if (_phone?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  _ReadOnlyProfileField(
                    label: 'Phone number',
                    icon: Icons.phone_outlined,
                    value: '+91 $_phone',
                  ),
                ],
              ],
      ),
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  const _ReadOnlyProfileField({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: UserDesignTokens.goldSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: UserDesignTokens.gold),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: UserDesignTokens.textSecondary,
              ),
            ),
            const Spacer(),
            Icon(Icons.lock_outline, size: 14, color: UserDesignTokens.textMuted),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: UserDesignTokens.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
            border: Border.all(color: UserDesignTokens.cardBorder),
          ),
          child: Text(
            value,
            style: AppTypography.inter(
              color: UserDesignTokens.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = value?.trim().isNotEmpty == true ? value!.trim() : 'Not set';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: UserDesignTokens.premiumCard(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: UserDesignTokens.gold, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.inter(
                      fontSize: 12,
                      color: UserDesignTokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    display,
                    style: AppTypography.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: display == 'Not set'
                          ? UserDesignTokens.textMuted
                          : UserDesignTokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
