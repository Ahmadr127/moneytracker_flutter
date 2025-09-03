# Money Tracker App

Aplikasi Flutter untuk tracking keuangan pribadi dengan fitur autentikasi yang lengkap.

## 🏗️ Struktur Project

### 1. Config/
- **constants.dart** → Variabel global (table name, key, validation rules, error messages)
- **theme/** → Konfigurasi tema light/dark dengan Material 3
- **routes.dart** → Daftar route ke setiap page

### 2. Core/
- **error/** → Mapping error Supabase ke pesan user-friendly
- **network/** → Supabase client wrapper dengan extension methods
- **utils/** → Helper functions (format tanggal, format uang, validator form)

### 3. Data/
- **models/** → Representasi tabel Supabase ke Dart (UserModel)
- **services/** → Panggilan API Supabase (AuthService)
- **repositories/** → Gabungan service + logic tambahan (AuthRepository)

### 4. Presentation/
- **pages/** → Setiap halaman (login, register, home)
- **widgets/** → Widget reusable (custom button, text field)

### 5. State/
- **auth_state.dart** → State management untuk autentikasi
- **theme_state.dart** → State management untuk tema

## 🚀 Fitur yang Tersedia

### Authentication
- ✅ Login dengan email & password
- ✅ Register dengan validasi lengkap
- ✅ Logout
- ✅ Error handling yang user-friendly
- ✅ Session management

### UI/UX
- ✅ Material 3 Design
- ✅ Light/Dark theme support
- ✅ Responsive design
- ✅ Custom components
- ✅ Form validation

### Architecture
- ✅ Clean Architecture pattern
- ✅ Repository pattern
- ✅ State management dengan Provider
- ✅ Error handling yang robust
- ✅ Constants management

## 📱 Screenshots

### Login Page
- Form login dengan validasi real-time
- Error handling yang informatif
- UI yang modern dan clean

### Register Page
- Form registrasi lengkap
- Validasi password confirmation
- Feedback yang jelas untuk user

### Home Page
- Dashboard dengan tab navigation
- Overview keuangan
- Quick actions
- Profile management

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9+
- **Backend**: Supabase (Auth + Database)
- **State Management**: Provider (akan diimplementasikan)
- **Architecture**: Clean Architecture
- **UI**: Material 3

## 📋 Requirements

- Flutter SDK 3.9.0 atau lebih tinggi
- Dart 3.0.0 atau lebih tinggi
- Android Studio / VS Code
- Supabase account

## 🔧 Setup & Installation

1. Clone repository
```bash
git clone <repository-url>
cd moneytracker
```

2. Install dependencies
```bash
flutter pub get
```

3. Setup Supabase
   - Buat project di [supabase.com](https://supabase.com)
   - Copy URL dan anon key ke `lib/config/constants.dart`

4. Run aplikasi
```bash
flutter run
```

## 🗄️ Database Schema

### Tables
- **users** - User authentication
- **profiles** - User profile information
- **transactions** - Financial transactions
- **categories** - Transaction categories
- **wallets** - User wallets

## 🔐 Environment Variables

Update `lib/config/constants.dart` dengan kredensial Supabase Anda:

```dart
class AppConstants {
  static const String baseUrl = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  // ... other constants
}
```

## 📁 File Structure

```
lib/
├── config/
│   ├── constants.dart
│   ├── routes.dart
│   └── theme/
│       └── app_theme.dart
├── core/
│   ├── error/
│   │   └── auth_error.dart
│   ├── network/
│   │   └── supabase_client.dart
│   └── utils/
│       ├── date_formatter.dart
│       ├── currency_formatter.dart
│       └── validators.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── services/
│       └── auth_service.dart
├── presentation/
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── custom_text_field.dart
├── state/
│   ├── auth_state.dart
│   └── theme_state.dart
└── main.dart
```

## 🎯 Roadmap

### Phase 1 (Current) ✅
- [x] Basic authentication
- [x] UI components
- [x] Theme system
- [x] Error handling

### Phase 2 (Next)
- [ ] Transaction management
- [ ] Category management
- [ ] Wallet management
- [ ] Reports & analytics

### Phase 3 (Future)
- [ ] Multi-currency support
- [ ] Budget planning
- [ ] Export functionality
- [ ] Push notifications

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

Jika ada pertanyaan atau masalah, silakan buat issue di repository ini.

---

**Note**: Project ini masih dalam tahap development. Fitur-fitur akan ditambahkan secara bertahap sesuai roadmap.
# moneytracker_flutter
