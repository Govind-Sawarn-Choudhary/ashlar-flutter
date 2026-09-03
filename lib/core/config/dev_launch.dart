import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';

/// Dev-only launch target. Toggle [enabled] off before release.
///
/// **Hot restart (`R`)** resets the app back to [route].
/// File saves should hot **reload** only — see `.vscode/settings.json`.
abstract final class DevLaunch {
  static const bool enabled = false;
  static const String route = UserRoutes.login;
}
