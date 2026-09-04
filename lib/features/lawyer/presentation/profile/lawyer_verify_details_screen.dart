import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_form_field.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_setup_step_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lawyer onboarding step 1 — personal and professional details.
class LawyerVerifyDetailsScreen extends StatefulWidget {
  const LawyerVerifyDetailsScreen({super.key});

  @override
  State<LawyerVerifyDetailsScreen> createState() =>
      _LawyerVerifyDetailsScreenState();
}

class _LawyerVerifyDetailsScreenState extends State<LawyerVerifyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _fullNameController = TextEditingController();
  final _practiceAreasController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _fullNameFocus = FocusNode();
  final _practiceFocus = FocusNode();
  final _experienceFocus = FocusNode();
  final _bioFocus = FocusNode();
  final _bioFieldKey = GlobalKey();

  bool _isSaving = false;
  bool _loading = true;
  bool _nameLocked = false;
  String? _barCouncilNameHint;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _bioFocus.addListener(_onBioFocusChanged);
    _loadExistingProfile();
  }

  void _onBioFocusChanged() {
    if (_bioFocus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _bioFieldKey.currentContext;
        if (context != null && mounted) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: 0.2,
          );
        }
      });
    }
  }

  Future<void> _loadExistingProfile() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final profile = response.lawyer;
      _fullNameController.text =
          profile.fullName ?? profile.barVerifiedName ?? '';
      _practiceAreasController.text = profile.practiceAreas ?? '';
      _experienceController.text = profile.experienceYears ?? '';
      _bioController.text = profile.bio ?? '';
      _nameLocked = profile.barEnrollmentVerified;
      _barCouncilNameHint = profile.barVerifiedName;
    } on ApiException catch (e) {
      _loadError = e.message;
    } catch (_) {
      _loadError = 'Could not load your profile';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _bioFocus.removeListener(_onBioFocusChanged);
    _scrollController.dispose();
    _fullNameController.dispose();
    _practiceAreasController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _fullNameFocus.dispose();
    _practiceFocus.dispose();
    _experienceFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_isSaving || _loading) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await LawyerProfileRepository.instance.saveDetails(
        fullName: _fullNameController.text.trim(),
        practiceAreas: _practiceAreasController.text.trim(),
        experienceYears: _experienceController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      final route = LawyerAuthRepository.instance.routeForNextStep(
        response.nextRoute,
      );
      Navigator.of(context).pushReplacementNamed(route);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save details. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    await AuthSession.instance.clear();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/role-select',
      (route) => false,
    );
  }

  String? _validateFullName(String? value) {
    if (_nameLocked) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Enter your complete name';
    }
    return null;
  }

  String? _validateExperience(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final years = int.tryParse(text);
    if (years == null) {
      return 'Enter experience in years (numbers only)';
    }
    if (years < 0 || years > 60) {
      return 'Enter a valid experience between 0 and 60 years';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          if (_loading) {
            return const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (_loadError != null) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(s.s(24)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _loadError!,
                        textAlign: TextAlign.center,
                        style: AppTypography.inter(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: s.s(16)),
                      TextButton(
                        onPressed: _loadExistingProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                SizedBox(height: s.s(8)),
                LawyerSetupStepBar(
                  scale: s,
                  activeStep: 0,
                  showProgressTracks: true,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(s.s(20), s.s(16), s.s(20), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Your Details',
                        style: AppTypography.inter(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: s.fs(20),
                        ),
                      ),
                      SizedBox(height: s.s(6)),
                      Text(
                        'Step 1 of 3 — Add your professional profile. Clients see this when booking you.',
                        style: AppTypography.inter(
                          color: Colors.white70,
                          fontSize: s.fs(13),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(s.s(20), s.s(16), s.s(20), s.s(16)),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(s.s(16)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(s.s(12)),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_nameLocked)
                            _VerifiedNameCard(
                              scale: s,
                              name: _fullNameController.text,
                            )
                          else
                            LawyerFormField(
                              scale: s,
                              label: 'Full name *',
                              hint: 'As on Bar Council records',
                              helperText: _barCouncilNameHint?.isNotEmpty == true
                                  ? 'Bar Council name on file: $_barCouncilNameHint'
                                  : 'Use your name as registered with Bar Council',
                              controller: _fullNameController,
                              focusNode: _fullNameFocus,
                              width: double.infinity,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _practiceFocus.requestFocus(),
                              validator: _validateFullName,
                            ),
                          if (_nameLocked) ...[
                            SizedBox(height: s.s(16)),
                          ] else ...[
                            SizedBox(height: s.s(18)),
                          ],
                          LawyerFormField(
                            scale: s,
                            label: 'Practice areas',
                            hint: 'e.g. Criminal, Civil, Family Law',
                            helperText: 'Separate multiple areas with commas',
                            controller: _practiceAreasController,
                            focusNode: _practiceFocus,
                            width: double.infinity,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _experienceFocus.requestFocus(),
                          ),
                          SizedBox(height: s.s(18)),
                          LawyerFormField(
                            scale: s,
                            label: 'Experience (years)',
                            hint: 'e.g. 8',
                            controller: _experienceController,
                            focusNode: _experienceFocus,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            width: double.infinity,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _bioFocus.requestFocus(),
                            validator: _validateExperience,
                          ),
                          SizedBox(height: s.s(18)),
                          KeyedSubtree(
                            key: _bioFieldKey,
                            child: LawyerFormField(
                              scale: s,
                              label: 'Professional bio',
                              hint: 'Brief introduction for clients…',
                              helperText: 'Max 500 characters',
                              controller: _bioController,
                              focusNode: _bioFocus,
                              height: 120,
                              maxLines: 5,
                              maxLength: 500,
                              hintPaddingLeft: 20,
                              hintPaddingTop: 15,
                              width: double.infinity,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _onContinue(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    s.s(18),
                    s.s(8),
                    s.s(18),
                    s.s(12) + (keyboardInset > 0 ? keyboardInset : 0),
                  ),
                  child: Opacity(
                    opacity: _isSaving ? 0.55 : 1,
                    child: IgnorePointer(
                      ignoring: _isSaving,
                      child: SizedBox(
                        width: double.infinity,
                        height: s.s(52),
                        child: GoldActionButton(
                          label: _isSaving ? 'Saving…' : 'Save & Continue',
                          onTap: _onContinue,
                          scaleX: s.scale,
                          scaleY: s.scale,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _isSaving ? null : _signOut,
                    child: Text(
                      'Sign out',
                      style: AppTypography.inter(
                        color: Colors.white54,
                        fontSize: s.fs(13),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: s.s(4)),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}

class _VerifiedNameCard extends StatelessWidget {
  const _VerifiedNameCard({
    required this.scale,
    required this.name,
  });

  final FigmaScale scale;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full name',
          style: AppTypography.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: scale.fs(13),
          ),
        ),
        SizedBox(height: scale.s(6)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: scale.s(16),
            vertical: scale.s(14),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(scale.s(10)),
            border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color: Colors.green.shade700,
                size: scale.s(20),
              ),
              SizedBox(width: scale.s(10)),
              Expanded(
                child: Text(
                  name.isEmpty ? 'Verified advocate' : name,
                  style: AppTypography.inter(
                    color: const Color(0xFF212121),
                    fontWeight: FontWeight.w600,
                    fontSize: scale.fs(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: scale.s(6)),
        Text(
          'Locked — verified from Bar Council records',
          style: AppTypography.inter(
            color: Colors.greenAccent,
            fontSize: scale.fs(11),
          ),
        ),
      ],
    );
  }
}
