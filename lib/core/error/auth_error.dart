class AuthError {
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'Invalid login credentials':
        return 'Email atau password salah. Silakan cek kembali.';
      case 'Email not confirmed':
        return 'Email belum diverifikasi. Silakan cek email Anda.';
      case 'User already registered':
        return 'Email sudah terdaftar. Silakan gunakan email lain.';
      case 'Password should be at least 6 characters':
        return 'Password minimal 6 karakter.';
      case 'Invalid email':
        return 'Format email tidak valid.';
      case 'User not found':
        return 'User tidak ditemukan.';
      case 'Too many requests':
        return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
      case 'Network error':
        return 'Kesalahan jaringan. Silakan cek koneksi internet Anda.';
      case 'Invalid token':
        return 'Sesi telah berakhir. Silakan login kembali.';
      case 'User already signed in':
        return 'User sudah login di perangkat lain.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  static String getSupabaseErrorMessage(dynamic error) {
    if (error == null) return 'Terjadi kesalahan yang tidak diketahui.';
    
    String errorString = error.toString().toLowerCase();
    
    // Database errors
    if (errorString.contains('profiles') || errorString.contains('pgrst205')) {
      return 'Akun berhasil dibuat, tetapi ada masalah dengan database. Silakan hubungi admin.';
    } else if (errorString.contains('table') && errorString.contains('not found')) {
      return 'Database belum siap. Silakan hubungi admin.';
    }
    
    // Auth errors
    if (errorString.contains('invalid login credentials') || errorString.contains('invalid_credentials')) {
      return 'Email atau password salah. Silakan cek kembali.';
    } else if (errorString.contains('email not confirmed') || errorString.contains('email_not_confirmed')) {
      return 'Email belum diverifikasi. Silakan cek email Anda dan klik link verifikasi.';
    } else if (errorString.contains('user already registered')) {
      return 'Email sudah terdaftar. Silakan gunakan email lain.';
    } else if (errorString.contains('password should be at least')) {
      return 'Password minimal 6 karakter.';
    } else if (errorString.contains('invalid email')) {
      return 'Format email tidak valid.';
    } else if (errorString.contains('user not found')) {
      return 'User tidak ditemukan.';
    } else if (errorString.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Kesalahan jaringan. Silakan cek koneksi internet Anda.';
    } else if (errorString.contains('invalid token')) {
      return 'Sesi telah berakhir. Silakan login kembali.';
    } else if (errorString.contains('already signed in')) {
      return 'User sudah login di perangkat lain.';
     } else if (errorString.contains('rangeerror') || errorString.contains('invalid value')) {
      return 'Login berhasil, tetapi ada masalah teknis. Silakan coba lagi.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
