class CurrencyConverter {
  // Tasa de cambio aproximada COP a USD (puedes actualizarla según la API real)
  static const double copToUsdRate = 0.00025; // 1 COP ≈ 0.00025 USD

  static double copToUsd(int cop) {
    return cop * copToUsdRate;
  }

  static int usdToCop(double usd) {
    return (usd / copToUsdRate).round();
  }

  static String formatCop(int cop) {
    return 'COP $cop';
  }

  static String formatUsd(double usd) {
    return '\$${usd.toStringAsFixed(2)} USD';
  }
}
