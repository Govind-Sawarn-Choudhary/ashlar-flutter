/// Fallback when wallet API has not loaded yet (matches platform default ₹100).
abstract final class WalletConfig {
  static const double defaultMinTopup = 100;
}