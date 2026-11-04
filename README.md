# FinTrack AI

**An AI-Powered Personal Finance & Expense Tracking Application**

FinTrack AI is an advanced mobile financial management platform that automates expense categorization, provides intelligent financial insights, and secures user data with banking-level protection. Built with Flutter for seamless cross-platform performance, it integrates cutting-edge AI technologies to deliver a modern, intuitive personal finance experience.

---

## Project Vision & Identity

FinTrack AI transforms personal finance management by combining artificial intelligence with robust security. Users can instantly capture expenses through voice or receipt scanning, receive AI-powered insights into spending patterns, and maintain complete control over their financial data through biometric-protected access and end-to-end encryption.

**Mission:** Empower users to take control of their finances with intelligent automation and actionable insights, backed by enterprise-grade security.

**Target Users:** Individuals seeking intelligent expense tracking, freelancers managing multiple income streams, and anyone who values financial transparency and data privacy.

---

## Key Features

### 🤖 AI-Powered Input
- **Smart Receipt Scanning**: Optical Character Recognition (OCR) combined with Gemini API integration to extract transaction amounts, vendor information, and line items from receipt photos
- **Voice-to-Text Expense Entry**: Natural Language Processing for hands-free expense logging with automatic category inference
- **Intelligent Categorization**: Machine learning-driven automatic expense classification with user refinement capabilities

### 🔒 Advanced Security (App Lock)
- **Multi-Layer Authentication**:
  - Google OAuth and Email/Password authentication for cloud identity
  - OS-level biometric authentication (fingerprint, face recognition)
  - PIN-based fallback access
  - Completely decoupled local security from cloud sessions
- **Secure Storage**: Encrypted local storage for sensitive data using flutter_secure_storage
- **Banking-Grade Protection**: Session management, token refresh, and secure credential handling

### 📊 Dynamic Financial Engine
- **Real-Time Dashboard**: Interactive visualizations of income, expenses, and financial trends
- **Multi-Currency Support**: Automatic currency conversion and localized transaction tracking
- **Granular Transaction Management**: Firestore Sub-collections for hierarchical expense organization
- **Advanced Filtering & Search**: Find transactions by date, category, amount, or custom queries
- **Financial Reports**: Monthly summaries, spending patterns, and budget recommendations

### 💰 Budget Management
- **Custom Budget Creation**: Set spending limits by category with flexible time periods
- **Budget Alerts**: Real-time notifications when approaching or exceeding budget thresholds
- **Spending Analytics**: Visual breakdown of actual vs. budgeted spending

### 🌍 Cross-Platform Accessibility
- **iOS & Android Native Performance**: Built with Flutter for optimal platform-specific experiences
- **Cloud Synchronization**: Seamless data sync across devices using Firebase Cloud Firestore
- **Offline Capability**: Core functionality available without internet connectivity

---

## Architecture & Tech Stack

### Frontend Framework
- **Flutter (Dart)**: Cross-platform mobile development with native performance

### Architecture Pattern
- **Feature-First Clean Architecture**: Organized for scalability and maintainability
  - Separation of concerns (UI, Domain, Data layers)
  - Feature-based modularization
  - Dependency injection and inversion of control

### State Management
- **hooks_riverpod**: Reactive business logic and global state management
- **flutter_hooks**: Efficient local widget state management with hook-based composition

### Backend & Cloud Services
- **Firebase Authentication**: OAuth, Email/Password, Multi-factor authentication
- **Cloud Firestore**: Scalable NoSQL database with real-time synchronization
- **Firebase Storage**: Secure file storage for receipts and user documents

### Security & Local Storage
- **local_auth**: OS-level biometric and PIN authentication
- **flutter_secure_storage**: Platform-specific encrypted credential storage
- **TLS/SSL**: Encrypted communication channels for all network requests

### AI & NLP Integration
- **Google Gemini API**: Advanced receipt analysis and intelligent categorization
- **OCR Processing**: Optical character recognition for receipt digitization
- **Natural Language Processing**: Voice command interpretation and entity extraction

### Additional Core Dependencies
- **http & dio**: HTTP client libraries for API communication
- **uuid**: Unique identifier generation for transactions
- **intl**: Internationalization and localization support
- **permission_handler**: Runtime permissions management
- **image_picker**: Camera and gallery access for receipt scanning
- **google_sign_in**: Google OAuth integration

---

## Folder Structure

```
fin_track_ai/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── error_messages.dart
│   │   ├── utils/
│   │   │   ├── app_logger.dart
│   │   │   ├── currency_converter.dart
│   │   │   └── date_formatter.dart
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart
│   │   │   ├── num_extensions.dart
│   │   │   └── datetime_extensions.dart
│   │   ├── services/
│   │   │   ├── firebase_service.dart
│   │   │   ├── local_auth_service.dart
│   │   │   └── secure_storage_service.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── app_colors.dart
│   │       └── app_text_styles.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in_usecase.dart
│   │   │   │       ├── sign_up_usecase.dart
│   │   │   │       └── verify_biometric_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── auth_controller.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── signup_page.dart
│   │   │       │   └── biometric_lock_page.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── oauth_buttons.dart
│   │   │
│   │   ├── transactions/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── transaction_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── transaction_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── transaction_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── transaction.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── transaction_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── add_transaction_usecase.dart
│   │   │   │       ├── fetch_transactions_usecase.dart
│   │   │   │       ├── delete_transaction_usecase.dart
│   │   │   │       └── filter_transactions_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── transaction_controller.dart
│   │   │       ├── pages/
│   │   │       │   ├── transactions_page.dart
│   │   │       │   └── transaction_detail_page.dart
│   │   │       └── widgets/
│   │   │           ├── transaction_card.dart
│   │   │           ├── transaction_form.dart
│   │   │           └── transaction_list.dart
│   │   │
│   │   ├── ai_insights/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── gemini_datasource.dart
│   │   │   │   │   └── analytics_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── insight_model.dart
│   │   │   │   │   └── receipt_analysis_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── insight_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── insight.dart
│   │   │   │   │   └── receipt_data.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── insight_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── analyze_receipt_usecase.dart
│   │   │   │       ├── generate_insights_usecase.dart
│   │   │   │       └── get_spending_trends_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── insight_controller.dart
│   │   │       ├── pages/
│   │   │       │   └── insights_page.dart
│   │   │       └── widgets/
│   │   │           ├── insight_card.dart
│   │   │           └── spending_chart.dart
│   │   │
│   │   └── home/
│   │       ├── presentation/
│   │       │   ├── pages/
│   │       │   │   └── home_page.dart
│   │       │   └── widgets/
│   │       │       ├── dashboard_header.dart
│   │       │       ├── quick_stats.dart
│   │       │       └── navigation_bar.dart
│   │
│   ├── config/
│   │   ├── routes/
│   │   │   └── app_router.dart
│   │   ├── di/
│   │   │   └── service_locator.dart
│   │   └── firebase/
│   │       └── firebase_options.dart
│   │
│   └── main.dart
│
├── pubspec.yaml
├── firebase.json
├── .env.example
└── README.md
```

---

## Setup & Installation

### Prerequisites
- Flutter SDK 3.13 or higher
- Dart SDK 3.13 or higher
- Xcode 14+ (for iOS development)
- Android Studio 2022.1+ (for Android development)
- Firebase project configured (Authentication, Firestore, Storage enabled)
- Google Cloud project with Gemini API enabled

### Step 1: Clone Repository
```bash
git clone https://github.com/FadiAbdElJawwad/FinTrack-AI.git
cd fin_track_ai
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Configure Firebase
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable these services:
   - Authentication (Email/Password, Google Sign-In)
   - Cloud Firestore
   - Firebase Storage
3. Download Firebase configuration:
   - **iOS**: `GoogleService-Info.plist` → Place in `ios/Runner/`
   - **Android**: `google-services.json` → Place in `android/app/`

### Step 4: Environment Configuration

Secrets and environment variables are injected via `--dart-define` flags at build/run time.

Required variables (see `.env.example` for reference):
- `APPS_SCRIPT_PROXY_URL`: Google Apps Script proxy endpoint
- `APP_SHARED_SECRET`: Shared secret for proxy authentication

### Step 5: Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 6: Run Application

**Development (Debug Mode)**
```bash
flutter run \
  --dart-define=APPS_SCRIPT_PROXY_URL=your_proxy_url \
  --dart-define=APP_SHARED_SECRET=your_shared_secret
```

**Release Mode**
```bash
# iOS
flutter build ios --release \
  --dart-define=APPS_SCRIPT_PROXY_URL=your_proxy_url \
  --dart-define=APP_SHARED_SECRET=your_shared_secret

# Android
flutter build apk --release \
  --dart-define=APPS_SCRIPT_PROXY_URL=your_proxy_url \
  --dart-define=APP_SHARED_SECRET=your_shared_secret
flutter build appbundle --release \
  --dart-define=APPS_SCRIPT_PROXY_URL=your_proxy_url \
  --dart-define=APP_SHARED_SECRET=your_shared_secret
```

---

## Security Considerations

### Authentication Flow
- Cloud authentication (Firebase) handles user identity and session management
- Local biometric/PIN provides OS-level access control, independent of cloud state
- Credentials stored securely using platform-specific encrypted storage

### Data Protection
- All Firestore transactions use HTTPS/TLS encryption
- Sensitive data at rest encrypted using flutter_secure_storage
- Firebase Security Rules enforce user-level access controls
- Receipt images stored in Firebase Storage with access restrictions

### Privacy
- User data never shared with third parties beyond Firebase and Gemini APIs
- Biometric data never transmitted or stored in cloud
- Users retain full control over data deletion and export

---

## API Integration

### Google Gemini API
- Receipt image analysis and OCR
- Expense categorization intelligence
- Spending pattern analysis and recommendations

### Firebase APIs
- Real-time database synchronization
- User authentication and session management
- File storage and retrieval

---

## Performance Optimization

- **Lazy Loading**: Transactions and insights loaded on demand
- **Caching**: Local caching of frequently accessed data
- **Image Optimization**: Automatic compression of receipt images before upload
- **Efficient Queries**: Indexed Firestore queries for fast data retrieval
- **State Management**: hooks_riverpod providers prevent unnecessary rebuilds

---

## Troubleshooting

### Common Issues

**Firebase Connection Failed**
- Verify Firebase configuration files are in correct locations
- Check Firebase project has required services enabled
- Confirm internet connectivity

**Biometric Authentication Not Working**
- Ensure device supports biometric authentication
- Verify app has biometric permission in iOS/Android settings
- On Android, ensure compatible sensors are configured

**Receipt Scanning Errors**
- Confirm camera permissions granted
- Ensure receipt image is clear and well-lit
- Verify Gemini API quota not exceeded

---

## Contributing

We welcome contributions to FinTrack AI. Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit changes: `git commit -am 'Add feature description'`
4. Push to branch: `git push origin feature/your-feature-name`
5. Submit a Pull Request

### Code Standards
- Follow Dart style guide: [Dart Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

## Support & Contact

For bug reports, feature requests, or questions:
- Open an issue on [GitHub Issues](https://github.com/FadiAbdElJawwad/FinTrack-AI/issues)
- Email: support@fintrackailabs.com

---


## Acknowledgments

- [Flutter Documentation](https://flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Gemini API](https://ai.google.dev)
- Open-source community contributors

---

## Local Setup

To run the app locally with AI features enabled:

1. Copy `config/dev.example.json` to `config/dev.local.json`:
   ```bash
   cp config/dev.example.json config/dev.local.json
   ```
2. Open `config/dev.local.json` and replace the placeholder values (`REPLACE_ME`) with your actual configuration secrets (`APPS_SCRIPT_PROXY_URL` and `APP_SHARED_SECRET`).
3. Press **Run** in Android Studio (selecting the `fin_track_ai (dev)` configuration) or VS Code (selecting `fin_track_ai (dev)`). Alternatively, run from CLI:
   ```bash
   flutter run --dart-define-from-file=config/dev.local.json
   ```

> **Note:** `config/dev.local.json` is git-ignored and will never be committed to version control.

