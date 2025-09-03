class CurrencyFormatter {
  static const String _currencySymbol = 'Rp';
  static const String _thousandSeparator = '.';
  static const String _decimalSeparator = ',';
  
  // Format angka ke format mata uang Indonesia
  static String formatCurrency(double amount) {
    if (amount == 0) return '$_currencySymbol 0';
    
    // Handle angka negatif
    bool isNegative = amount < 0;
    double absAmount = amount.abs();
    
    // Format dengan separator ribuan
    String formattedAmount = _formatNumber(absAmount);
    
    // Tambahkan simbol mata uang
    String result = '$_currencySymbol $formattedAmount';
    
    // Tambahkan tanda negatif jika perlu
    if (isNegative) {
      result = '-$result';
    }
    
    return result;
  }
  
  // Format angka ke format mata uang tanpa simbol
  static String formatNumber(double amount) {
    return _formatNumber(amount.abs());
  }
  
  // Format angka dengan separator ribuan
  static String _formatNumber(double amount) {
    // Konversi ke integer (hilangkan desimal)
    int intAmount = amount.toInt();
    
    // Format dengan separator ribuan
    String result = intAmount.toString();
    
    // Tambahkan separator ribuan setiap 3 digit dari kanan
    for (int i = result.length - 3; i > 0; i -= 3) {
      result = result.substring(0, i) + _thousandSeparator + result.substring(i);
    }
    
    return result;
  }
  
  // Parse string mata uang ke double
  static double? parseCurrency(String currencyString) {
    try {
      // Hapus simbol mata uang dan spasi
      String cleanString = currencyString
          .replaceAll(_currencySymbol, '')
          .replaceAll(' ', '')
          .replaceAll(_thousandSeparator, '');
      
      // Parse ke double
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }
  
  // Format persentase
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  // Format angka dengan suffix (K, M, B)
  static String formatCompact(double amount) {
    if (amount < 1000) {
      return formatCurrency(amount);
    } else if (amount < 1000000) {
      return '${_currencySymbol} ${(amount / 1000).toStringAsFixed(1)}K';
    } else if (amount < 1000000000) {
      return '${_currencySymbol} ${(amount / 1000000).toStringAsFixed(1)}M';
    } else {
      return '${_currencySymbol} ${(amount / 1000000000).toStringAsFixed(1)}B';
    }
  }
  
  // Format range mata uang
  static String formatRange(double min, double max) {
    return '${formatCurrency(min)} - ${formatCurrency(max)}';
  }
}
