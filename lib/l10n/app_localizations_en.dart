// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FinTrack AI';

  @override
  String get splashBody => 'Smart Financial Tracking';

  @override
  String get onboardingTitle1 => 'Smart Financial Tracking';

  @override
  String get onboardingBody1 =>
      'Connect your accounts and let our AI categorize every transaction automatically.';

  @override
  String get onboardingTitle2 => 'AI-Powered Insights';

  @override
  String get onboardingBody2 =>
      'Scan receipts and get personalized advice to optimize your spending habits.';

  @override
  String get onboardingTitle3 => 'Grow Your Wealth';

  @override
  String get onboardingBody3 =>
      'Set smart budgets and watch your savings grow with predictive financial planning.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get signupTitle => 'Create an Account';

  @override
  String get loginBody => 'Log in to manage your portfolio';

  @override
  String get fingerPrintLogin => 'Log in with Fingerprint/FaceID';

  @override
  String get signupBody => 'Enter your details to get started.';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordBody =>
      'Enter your email to receive a password reset link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetPasswordSuccess =>
      'If this email is registered, a reset link has been sent.';

  @override
  String get fieldCannotBeEmpty => 'This field cannot be empty';

  @override
  String get emptyName => 'Name cannot be empty';

  @override
  String get emptyEmail => 'Email cannot be empty';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get emptyPassword => 'Password cannot be empty';

  @override
  String get invalidPassword => 'Password must be at least 6 characters long';

  @override
  String get passwordSameAsCurrent =>
      'New password cannot be the same as the current password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get userNotFound => 'No user found with this email.';

  @override
  String get wrongPassword => 'Incorrect password.';

  @override
  String get invalidCredential => 'Invalid email or password.';

  @override
  String get emailAlreadyInUse => 'Email is already registered.';

  @override
  String get invalidEmailAuth => 'The email address is invalid.';

  @override
  String get weakPasswordAuth => 'The password is too weak.';

  @override
  String get userDisabled => 'This user account has been disabled.';

  @override
  String get tooManyRequests => 'Too many attempts. Please try again later.';

  @override
  String get networkRequestFailed =>
      'Network error. Please check your connection.';

  @override
  String get databaseError => 'A database error occurred.';

  @override
  String get unknownError => 'An unexpected error occurred.';

  @override
  String get biometricDenied => 'Biometric authentication denied or cancelled.';

  @override
  String get noSavedCredentials =>
      'No saved credentials found. Please log in with your email first.';

  @override
  String get enableBiometricLogin => 'Enable Biometric Login';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signInWithAnotherAccount => 'Sign in with another account';

  @override
  String get googleSignInCanceled => 'Google Sign-In was canceled.';

  @override
  String get scan => 'Scan';

  @override
  String get voice => 'Voice';

  @override
  String get add => 'Add';

  @override
  String get manual => 'Manual';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get transactions => 'Transactions';

  @override
  String get seeAll => 'See All';

  @override
  String get emptyTransactions => 'No transactions found.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get selectWallet => 'SELECT WALLET';

  @override
  String get category => 'CATEGORY';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get date => 'DATE';

  @override
  String get notes => 'NOTES';

  @override
  String get addNote => 'Add note...';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get cancel => 'Cancel';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get delete => 'Delete';

  @override
  String get status => 'Status';

  @override
  String get completed => 'Completed';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get type => 'Type';

  @override
  String get transactionDeleted => 'Transaction deleted.';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get all => 'All';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get dateRange => 'Date Range';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get quickPresets => 'QUICK PRESETS';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get customRange => 'CUSTOM RANGE';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get reset => 'Reset';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get rangeError => 'Date range cannot exceed one month';

  @override
  String get more => '+ More';

  @override
  String get sessionExpired => 'Your session has expired. Please log in again.';

  @override
  String get aiUnauthorized => 'Unable to verify request. Please try again.';

  @override
  String get aiInvalidInput =>
      'Couldn\'t understand that input. Try rephrasing.';

  @override
  String get aiServiceUnavailable => 'AI service is temporarily unavailable.';

  @override
  String get aiSchemaValidationFailed =>
      'Couldn\'t extract transaction details. Try again.';

  @override
  String get aiNetworkError => 'Network error. Check your connection.';

  @override
  String get aiNotConfigured => 'AI features are not configured.';

  @override
  String get aiUnknown => 'Something went wrong. Please try again.';

  @override
  String get micPermissionDenied =>
      'Microphone permission is required to use Voice Entry.';

  @override
  String get speechTimeout => 'No speech detected. Try again.';

  @override
  String get voiceEntryTitle => 'Voice Entry';

  @override
  String get listeningStatus => 'Listening...';

  @override
  String get processingStatus => 'Processing...';

  @override
  String get tapToSpeak => 'Tap to speak';

  @override
  String get tryAgainVoice => 'Please try again.';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get processingButton => 'Processing...';

  @override
  String get stopAndProcess => 'Stop & Process';

  @override
  String get catFood => 'Food';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catSalary => 'Salary';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catOther => 'Other';

  @override
  String get defaultWalletName => 'Cash';

  @override
  String get unknownWallet => 'Unknown';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get currencyChangeSuccess => 'Currency updated successfully.';

  @override
  String get currencyChangeFailed => 'Failed to update currency:';

  @override
  String get internetRequiredFirstLaunch =>
      'This app requires an internet connection on first launch.';

  @override
  String get exchangeRateServiceError =>
      'We couldn\'t load exchange rates right now. Please try again.';

  @override
  String get groupUpcoming => 'UPCOMING';

  @override
  String get groupToday => 'TODAY';

  @override
  String get groupYesterday => 'YESTERDAY';

  @override
  String get groupThisMonth => 'THIS MONTH';

  @override
  String get groupEarlier => 'EARLIER';

  @override
  String get bootErrorTitle => 'Initialization Failed';

  @override
  String get bootErrorMessage =>
      'Unable to initialize the app. Please check your connection and try again.';

  @override
  String transactionsWindowNote(int months) {
    return 'History available: last $months months';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navWallets => 'Wallets';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsPreferences => 'App Preferences';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeDark => 'Dark Theme';

  @override
  String get settingsThemeLight => 'Light Theme';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsBiometric => 'Biometric Authentication';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirmTitle => 'Log Out?';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get walletsYourAccounts => 'Your Accounts';

  @override
  String walletsBalanceWindowNote(int months) {
    return 'Balances cover the last $months months';
  }

  @override
  String get walletsUnassigned => 'Unassigned transactions';

  @override
  String get walletsEmpty => 'No wallets yet. Tap + to add one.';

  @override
  String get addWalletTitle => 'Add Wallet';

  @override
  String get openingBalanceLabel => 'OPENING BALANCE (OPTIONAL)';

  @override
  String get editWalletTitle => 'Edit Wallet';

  @override
  String get saveWallet => 'Save Changes';

  @override
  String get deleteWallet => 'Delete Wallet';

  @override
  String get deleteWalletConfirmTitle => 'Delete Wallet?';

  @override
  String get deleteWalletConfirmMessage =>
      'This wallet will be permanently deleted.';

  @override
  String walletHasTransactionsMessage(int months) {
    return 'This wallet has transactions in the last $months months. Move or delete them first.';
  }

  @override
  String get walletNameLabel => 'WALLET NAME';

  @override
  String get walletNameHint => 'e.g., Savings';

  @override
  String get walletIconLabel => 'ICON';

  @override
  String get createWallet => 'Create Wallet';

  @override
  String get walletNameExists => 'A wallet with this name already exists.';

  @override
  String get walletNameBank => 'Bank Account';

  @override
  String get walletNamePaypal => 'PayPal';

  @override
  String get walletNameOther => 'Other';

  @override
  String get analyticsPeriodWeek => 'Week';

  @override
  String get analyticsPeriodMonth => 'Month';

  @override
  String analyticsPeriodYear(int months) {
    return '$months Months';
  }

  @override
  String get analyticsExpensesByCategory => 'Expenses by Category';

  @override
  String get analyticsEmpty => 'No transactions in this period.';

  @override
  String get walletTypeLabel => 'WALLET TYPE';

  @override
  String get walletTypeEWallet => 'E-Wallet';

  @override
  String get invalidAmount => 'Invalid amount';
}
