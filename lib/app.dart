import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/widgets/feature_coming_soon_screen.dart';
import 'package:ashlar_lawyer_hub/core/config/dev_launch.dart';
import 'package:ashlar_lawyer_hub/core/navigation/app_navigator.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/lawyer_login_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/lawyer_otp_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/lawyer_verification_status_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/lawyer_shell_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/lawyer_dashboard_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/wallet/lawyer_wallet_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/notifications/lawyer_notification_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_my_profile_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_my_documents_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_manage_profile_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_manage_appointments_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/consultation/lawyer_consultation_history_screen.dart';
import 'package:ashlar_lawyer_hub/features/consultation/presentation/consultation_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_add_consultation_fee_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_fee_and_charges_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_select_availability_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_upload_documents_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_verify_details_screen.dart';
import 'package:ashlar_lawyer_hub/features/role_select/presentation/role_select_screen.dart';
import 'package:ashlar_lawyer_hub/features/splash/presentation/splash_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/user_shell_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/user_create_account_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/user_login_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/user_otp_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/user_dashboard_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/profile/user_manage_profile_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/profile/user_profile_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/user_appointment_preference_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/user_lawyers_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/user_booking_confirm_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/user_lawyer_detail_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/user_online_appointment_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/user_payment_success_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/documents/user_get_documents_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/models/user_challan_otp_args.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/models/user_challan_verify_otp_args.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/models/user_challan_status_args.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_payment_success_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_status_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_otp_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_verify_otp_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/wallet/user_wallet_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

class AshlarLawyerHubApp extends StatelessWidget {
  const AshlarLawyerHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Ashlar Lawyer Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.background,
        ),
        useMaterial3: true,
      ),
      initialRoute: DevLaunch.enabled ? DevLaunch.route : '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/role-select': (_) => const RoleSelectScreen(),
        '/user': (_) => const UserShellScreen(),
        UserRoutes.login: (_) => const UserLoginScreen(),
        UserRoutes.createAccount: (_) => const UserCreateAccountScreen(),
        UserRoutes.home: (_) => const UserDashboardScreen(),
        UserRoutes.lawyers: (_) => const UserLawyersScreen(),
        UserRoutes.documents: (_) => const UserGetDocumentsScreen(),
        UserRoutes.profile: (_) => const UserProfileScreen(),
        UserRoutes.challan: (_) => const UserChallanScreen(),
        LawyerRoutes.onboarding: (_) => const LawyerShellScreen(),
        LawyerRoutes.login: (_) => const LawyerLoginScreen(),
        LawyerRoutes.verifyDetails: (_) => const LawyerVerifyDetailsScreen(),
        LawyerRoutes.uploadDocuments: (_) => const LawyerUploadDocumentsScreen(),
        LawyerRoutes.selectAvailability: (_) =>
            const LawyerSelectAvailabilityScreen(),
        LawyerRoutes.feeAndCharges: (_) => const LawyerFeeAndChargesScreen(),
        LawyerRoutes.verificationStatus: (_) =>
            const LawyerVerificationStatusScreen(),
        LawyerRoutes.dashboard: (_) => const LawyerDashboardScreen(),
        LawyerRoutes.wallet: (_) => const LawyerWalletScreen(),
        LawyerRoutes.notifications: (_) => const LawyerNotificationScreen(),
        LawyerRoutes.profile: (_) => const LawyerMyProfileScreen(),
        LawyerRoutes.myDocuments: (_) => const LawyerMyDocumentsScreen(),
        LawyerRoutes.manageProfile: (_) => const LawyerManageProfileScreen(),
        LawyerRoutes.manageAppointments: (_) =>
            const LawyerManageAppointmentsScreen(),
        LawyerRoutes.consultationHistory: (_) =>
            const LawyerConsultationHistoryScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == LawyerRoutes.comingSoon) {
          final featureName = settings.arguments as String? ?? 'Feature';
          return MaterialPageRoute<void>(
            builder: (_) => FeatureComingSoonScreen(featureName: featureName),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.otp) {
          final phone = settings.arguments as String? ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => UserOtpScreen(phoneNumber: phone),
            settings: settings,
          );
        }
        if (settings.name == LawyerRoutes.otp) {
          final phone = settings.arguments as String? ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => LawyerOtpScreen(phoneNumber: phone),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.appointmentPreference) {
          final contextArg = settings.arguments as UserBookingContext?;
          if (contextArg == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserAppointmentPreferenceScreen(
              bookingContext: contextArg,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.onlineAppointment) {
          final contextArg = settings.arguments as UserBookingContext?;
          if (contextArg == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserOnlineAppointmentScreen(
              bookingContext: contextArg,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.lawyerDetail) {
          final contextArg = settings.arguments as UserBookingContext?;
          if (contextArg == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserLawyerDetailScreen(
              bookingContext: contextArg,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.bookingConfirm) {
          final contextArg = settings.arguments as UserBookingContext?;
          if (contextArg == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserBookingConfirmScreen(
              bookingContext: contextArg,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.challanPaymentSuccess) {
          final payment = settings.arguments as UserPaymentResult?;
          if (payment == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserChallanPaymentSuccessScreen(payment: payment),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.challanStatus) {
          final args = settings.arguments as UserChallanStatusArgs?;
          if (args == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserChallanStatusScreen(
              vehicleNumber: args.vehicleNumber,
              mobileNumber: args.mobileNumber,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.challanVerifyOtp) {
          final args = settings.arguments as UserChallanVerifyOtpArgs?;
          if (args == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserChallanVerifyOtpScreen(
              vehicleNumber: args.vehicleNumber,
              mobileNumber: args.mobileNumber,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.challanOtp) {
          final args = settings.arguments as UserChallanOtpArgs?;
          if (args == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserChallanOtpScreen(
              vehicleNumber: args.vehicleNumber,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.manageProfile) {
          return MaterialPageRoute<bool>(
            builder: (_) => const UserManageProfileScreen(),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.paymentSuccess) {
          final payment = settings.arguments as UserPaymentResult?;
          if (payment == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => UserPaymentSuccessScreen(payment: payment),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.consultation) {
          final args = settings.arguments as ConsultationScreenArgs?;
          if (args == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => ConsultationScreen(
              appointmentId: args.appointmentId,
              isLawyer: args.isLawyer,
              peerName: args.peerName,
            ),
            settings: settings,
          );
        }
        if (settings.name == LawyerRoutes.consultation) {
          final args = settings.arguments as ConsultationScreenArgs?;
          if (args == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => ConsultationScreen(
              appointmentId: args.appointmentId,
              isLawyer: args.isLawyer,
              peerName: args.peerName,
            ),
            settings: settings,
          );
        }
        if (settings.name == UserRoutes.wallet) {
          return MaterialPageRoute<void>(
            builder: (_) => const UserWalletScreen(),
            settings: settings,
          );
        }
        if (settings.name == LawyerRoutes.addConsultationFee) {
          final args = settings.arguments as LawyerAddConsultationFeeArgs?;
          if (args == null) {
            return null;
          }
          return MaterialPageRoute<LawyerConsultationFeeResult?>(
            builder: (_) => LawyerAddConsultationFeeScreen(
              consultationType: args.consultationType,
              initialAmount: args.initialAmount,
              initialDuration: args.initialDuration,
              initialLocation: args.initialLocation,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
