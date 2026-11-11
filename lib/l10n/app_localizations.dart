import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FinTrack AI'**
  String get appTitle;

  /// No description provided for @splashBody.
  ///
  /// In en, this message translates to:
  /// **'Smart Financial Tracking'**
  String get splashBody;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Smart Financial Tracking'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Connect your accounts and let our AI categorize every transaction automatically.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Insights'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Scan receipts and get personalized advice to optimize your spending habits.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Grow Your Wealth'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Set smart budgets and watch your savings grow with predictive financial planning.'**
  String get onboardingBody3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get signupTitle;

  /// No description provided for @loginBody.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your portfolio'**
  String get loginBody;

  /// No description provided for @fingerPrintLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in with Fingerprint/FaceID'**
  String get fingerPrintLogin;

  /// No description provided for @signupBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started.'**
  String get signupBody;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link'**
  String get resetPasswordBody;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'If this email is registered, a reset link has been sent.'**
  String get resetPasswordSuccess;

  /// No description provided for @fieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty'**
  String get fieldCannotBeEmpty;

  /// No description provided for @emptyName.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get emptyName;

  /// No description provided for @emptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emptyEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @emptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get emptyPassword;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get invalidPassword;

  /// No description provided for @passwordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'New password cannot be the same as the current password'**
  String get passwordSameAsCurrent;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get wrongPassword;

  /// No description provided for @invalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredential;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email is already registered.'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmailAuth.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get invalidEmailAuth;

  /// No description provided for @weakPasswordAuth.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get weakPasswordAuth;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get userDisabled;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyRequests;

  /// No description provided for @networkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkRequestFailed;

  /// No description provided for @databaseError.
  ///
  /// In en, this message translates to:
  /// **'A database error occurred.'**
  String get databaseError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unknownError;

  /// No description provided for @biometricDenied.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication denied or cancelled.'**
  String get biometricDenied;

  /// No description provided for @noSavedCredentials.
  ///
  /// In en, this message translates to:
  /// **'No saved credentials found. Please log in with your email first.'**
  String get noSavedCredentials;

  /// No description provided for @enableBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get enableBiometricLogin;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signInWithAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in with another account'**
  String get signInWithAnotherAccount;

  /// No description provided for @googleSignInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In was canceled.'**
  String get googleSignInCanceled;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @emptyTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found.'**
  String get emptyTransactions;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @selectWallet.
  ///
  /// In en, this message translates to:
  /// **'SELECT WALLET'**
  String get selectWallet;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get date;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get notes;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note...'**
  String get addNote;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted.'**
  String get transactionDeleted;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @quickPresets.
  ///
  /// In en, this message translates to:
  /// **'QUICK PRESETS'**
  String get quickPresets;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM RANGE'**
  String get customRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @rangeError.
  ///
  /// In en, this message translates to:
  /// **'Date range cannot exceed one month'**
  String get rangeError;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'+ More'**
  String get more;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @aiUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify request. Please try again.'**
  String get aiUnauthorized;

  /// No description provided for @aiInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t understand that input. Try rephrasing.'**
  String get aiInvalidInput;

  /// No description provided for @aiServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI service is temporarily unavailable.'**
  String get aiServiceUnavailable;

  /// No description provided for @aiSchemaValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t extract transaction details. Try again.'**
  String get aiSchemaValidationFailed;

  /// No description provided for @aiNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get aiNetworkError;

  /// No description provided for @aiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI features are not configured.'**
  String get aiNotConfigured;

  /// No description provided for @aiUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get aiUnknown;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to use Voice Entry.'**
  String get micPermissionDenied;

  /// No description provided for @speechTimeout.
  ///
  /// In en, this message translates to:
  /// **'No speech detected. Try again.'**
  String get speechTimeout;

  /// No description provided for @voiceEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Entry'**
  String get voiceEntryTitle;

  /// No description provided for @listeningStatus.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listeningStatus;

  /// No description provided for @processingStatus.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingStatus;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get tapToSpeak;

  /// No description provided for @tryAgainVoice.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get tryAgainVoice;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @processingButton.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingButton;

  /// No description provided for @stopAndProcess.
  ///
  /// In en, this message translates to:
  /// **'Stop & Process'**
  String get stopAndProcess;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @defaultWalletName.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get defaultWalletName;

  /// No description provided for @unknownWallet.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownWallet;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currencyChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Currency updated successfully.'**
  String get currencyChangeSuccess;

  /// No description provided for @currencyChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update currency:'**
  String get currencyChangeFailed;

  /// No description provided for @internetRequiredFirstLaunch.
  ///
  /// In en, this message translates to:
  /// **'This app requires an internet connection on first launch.'**
  String get internetRequiredFirstLaunch;

  /// No description provided for @exchangeRateServiceError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load exchange rates right now. Please try again.'**
  String get exchangeRateServiceError;

  /// No description provided for @groupUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get groupUpcoming;

  /// No description provided for @groupToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get groupToday;

  /// No description provided for @groupYesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get groupYesterday;

  /// No description provided for @groupThisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get groupThisMonth;

  /// No description provided for @groupEarlier.
  ///
  /// In en, this message translates to:
  /// **'EARLIER'**
  String get groupEarlier;

  /// No description provided for @bootErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Initialization Failed'**
  String get bootErrorTitle;

  /// No description provided for @bootErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to initialize the app. Please check your connection and try again.'**
  String get bootErrorMessage;

  /// No description provided for @transactionsWindowNote.
  ///
  /// In en, this message translates to:
  /// **'History available: last {months} months'**
  String transactionsWindowNote(int months);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get navWallets;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get settingsThemeLight;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get settingsBiometric;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutConfirmMessage;

  /// No description provided for @walletsYourAccounts.
  ///
  /// In en, this message translates to:
  /// **'Your Accounts'**
  String get walletsYourAccounts;

  /// No description provided for @walletsBalanceWindowNote.
  ///
  /// In en, this message translates to:
  /// **'Balances cover the last {months} months'**
  String walletsBalanceWindowNote(int months);

  /// No description provided for @walletsUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned transactions'**
  String get walletsUnassigned;

  /// No description provided for @walletsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet. Tap + to add one.'**
  String get walletsEmpty;

  /// No description provided for @addWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get addWalletTitle;

  /// No description provided for @openingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'OPENING BALANCE (OPTIONAL)'**
  String get openingBalanceLabel;

  /// No description provided for @editWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Wallet'**
  String get editWalletTitle;

  /// No description provided for @saveWallet.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveWallet;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet'**
  String get deleteWallet;

  /// No description provided for @deleteWalletConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet?'**
  String get deleteWalletConfirmTitle;

  /// No description provided for @deleteWalletConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This wallet will be permanently deleted.'**
  String get deleteWalletConfirmMessage;

  /// No description provided for @walletHasTransactionsMessage.
  ///
  /// In en, this message translates to:
  /// **'This wallet has transactions in the last {months} months. Move or delete them first.'**
  String walletHasTransactionsMessage(int months);

  /// No description provided for @walletNameLabel.
  ///
  /// In en, this message translates to:
  /// **'WALLET NAME'**
  String get walletNameLabel;

  /// No description provided for @walletNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Savings'**
  String get walletNameHint;

  /// No description provided for @walletIconLabel.
  ///
  /// In en, this message translates to:
  /// **'ICON'**
  String get walletIconLabel;

  /// No description provided for @createWallet.
  ///
  /// In en, this message translates to:
  /// **'Create Wallet'**
  String get createWallet;

  /// No description provided for @walletNameExists.
  ///
  /// In en, this message translates to:
  /// **'A wallet with this name already exists.'**
  String get walletNameExists;

  /// No description provided for @walletNameBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get walletNameBank;

  /// No description provided for @walletNamePaypal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get walletNamePaypal;

  /// No description provided for @walletNameOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get walletNameOther;

  /// No description provided for @analyticsPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get analyticsPeriodWeek;

  /// No description provided for @analyticsPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get analyticsPeriodMonth;

  /// No description provided for @analyticsPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'{months} Months'**
  String analyticsPeriodYear(int months);

  /// No description provided for @analyticsExpensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get analyticsExpensesByCategory;

  /// No description provided for @analyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period.'**
  String get analyticsEmpty;

  /// No description provided for @walletTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'WALLET TYPE'**
  String get walletTypeLabel;

  /// No description provided for @walletTypeEWallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get walletTypeEWallet;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
