class DateFormatter {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  
  // Format tanggal ke string yang readable
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }
  
  // Format waktu ke string
  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  // Format tanggal dan waktu
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }
  
  // Format bulan dan tahun
  static String formatMonthYear(DateTime date) {
    final month = _months[date.month - 1];
    final year = date.year.toString();
    return '$month $year';
  }
  
  // Format hari dan bulan
  static String formatDayMonth(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month';
  }
  
  // Format relative time (hari ini, kemarin, dll)
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference == -1) {
      return 'Besok';
    } else if (difference > 1 && difference < 7) {
      return '$difference hari yang lalu';
    } else if (difference < -1 && difference > -7) {
      return '${difference.abs()} hari lagi';
    } else {
      return formatDate(date);
    }
  }
  
  // Parse string ke DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  // Get current date
  static DateTime get now => DateTime.now();
  
  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
  
  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
}
