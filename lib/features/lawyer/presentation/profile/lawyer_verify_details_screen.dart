import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/core/widgets/keyboard_dismissible.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_form_field.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_section_heading.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_setup_step_bar.dart';
import 'package:flutter/material.dart';

/// Lawyer profile step 1 — personal details (Bar Council verify on documents step).
class LawyerVerifyDetailsScreen extends StatefulWidget {
  const LawyerVerifyDetailsScreen({super.key});

  @override
  State<LawyerVerifyDetailsScreen> createState() =>
      _LawyerVerifyDetailsScreenState();
}

class _LawyerVerifyDetailsScreenState extends State<LawyerVerifyDetailsScreen> {
  final _fullNameController = TextEditingController();
  final _practiceAreasController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isSaving = false;
  bool _nameLocked = false;
  String? _barCouncilNameHint;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final profile = response.lawyer;
      _fullNameController.text = profile.fullName ?? profile.barVerifiedName ?? '';
      _practiceAreasController.text = profile.practiceAreas ?? '';
      _experienceController.text = profile.experienceYears ?? '';
      _bioController.text = profile.bio ?? '';
      _nameLocked = profile.barEnrollmentVerified;
      _barCouncilNameHint = profile.barVerifiedName;
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // Fresh registration — fields stay empty.
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _practiceAreasController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (_isSaving) {
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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return Column(
            children: [
              SizedBox(height: s.s(113)),
              LawyerSectionHeading(
                title: 'Verify Your Details',
                scale: s,
                titleWidth: 143,
              ),
              SizedBox(height: s.s(8)),
              LawyerSetupStepBar(scale: s, activeStep: 0),
              Expanded(
                child: KeyboardAwareScrollView(
                  padding: EdgeInsets.fromLTRB(s.s(22), s.s(20), s.s(22), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_nameLocked)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: s.s(16),
                            vertical: s.s(14),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(s.s(10)),
                          ),
                          child: Text(
                            _fullNameController.text,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: s.fs(16),
                            ),
                          ),
                        )
                      else
                        LawyerFormField(
                          scale: s,
                          hint: 'Full Name (auto-updated from Bar Council)',
                          controller: _fullNameController,
                          width: double.infinity,
                        ),
                      if (_barCouncilNameHint?.isNotEmpty == true && !_nameLocked) ...[
                        SizedBox(height: s.s(6)),
                        Text(
                          'If incorrect, Bar Council verify will auto-correct your name',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: s.fs(10),
                          ),
                        ),
                      ],
                      if (_nameLocked) ...[
                        SizedBox(height: s.s(6)),
                        Text(
                          'Name verified from Bar Council records',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: s.fs(10),
                          ),
                        ),
                      ],
                      SizedBox(height: s.s(16)),
                      LawyerFormField(
                        scale: s,
                        hint: 'Practice Areas',
                        controller: _practiceAreasController,
                        width: double.infinity,
                      ),
                      SizedBox(height: s.s(16)),
                      LawyerFormField(
                        scale: s,
                        hint: 'Total Experience',
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        width: double.infinity,
                      ),
                      SizedBox(height: s.s(16)),
                      LawyerFormField(
                        scale: s,
                        hint: 'Bio',
                        controller: _bioController,
                        height: 103,
                        maxLines: 4,
                        hintPaddingLeft: 20,
                        hintPaddingTop: 15,
                        width: double.infinity,
                      ),
                      SizedBox(height: s.s(24)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  s.s(20),
                  s.s(8),
                  s.s(20),
                  s.s(24) + (keyboardInset > 0 ? keyboardInset : 0),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: s.s(52),
                  child: GoldActionButton(
                    label: _isSaving ? 'Saving…' : 'Continue',
                    onTap: _onContinue,
                    scaleX: s.scale,
                    scaleY: s.scale,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
