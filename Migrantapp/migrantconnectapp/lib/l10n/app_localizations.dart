import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeMessage;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @findJobs.
  ///
  /// In en, this message translates to:
  /// **'Find Jobs'**
  String get findJobs;

  /// No description provided for @findAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Find Accommodation'**
  String get findAccommodation;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// No description provided for @jobMarket.
  ///
  /// In en, this message translates to:
  /// **'Job Market'**
  String get jobMarket;

  /// No description provided for @filterByJobType.
  ///
  /// In en, this message translates to:
  /// **'Filter by Job Type'**
  String get filterByJobType;

  /// No description provided for @selectJobType.
  ///
  /// In en, this message translates to:
  /// **'Select Job Type'**
  String get selectJobType;

  /// No description provided for @filterByLocation.
  ///
  /// In en, this message translates to:
  /// **'Filter by Location (e.g., City, State)'**
  String get filterByLocation;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs found.'**
  String get noJobsFound;

  /// No description provided for @noJobsFoundMatchingCriteria.
  ///
  /// In en, this message translates to:
  /// **'No jobs found matching your criteria.'**
  String get noJobsFoundMatchingCriteria;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get posted;

  /// No description provided for @areYouALandOwner.
  ///
  /// In en, this message translates to:
  /// **'Are you an Employer?'**
  String get areYouALandOwner;

  /// No description provided for @jobTypeAgriculture.
  ///
  /// In en, this message translates to:
  /// **'Agriculture'**
  String get jobTypeAgriculture;

  /// No description provided for @jobTypeConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get jobTypeConstruction;

  /// No description provided for @jobTypeDomesticHelp.
  ///
  /// In en, this message translates to:
  /// **'Domestic Help'**
  String get jobTypeDomesticHelp;

  /// No description provided for @jobTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get jobTypeOther;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobType;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @couldNotLaunchPhoneDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer.'**
  String get couldNotLaunchPhoneDialer;

  /// No description provided for @postedByUserId.
  ///
  /// In en, this message translates to:
  /// **'Posted by User ID'**
  String get postedByUserId;

  /// No description provided for @postedOn.
  ///
  /// In en, this message translates to:
  /// **'Posted On'**
  String get postedOn;

  /// No description provided for @submitJobOffer.
  ///
  /// In en, this message translates to:
  /// **'Submit Job Offer'**
  String get submitJobOffer;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @pleaseEnterATitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterATitle;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription;

  /// No description provided for @pleaseEnterADescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterADescription;

  /// No description provided for @pleaseSelectAJobType.
  ///
  /// In en, this message translates to:
  /// **'Please select a job type'**
  String get pleaseSelectAJobType;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Location (e.g., City, State)'**
  String get locationHint;

  /// No description provided for @pleaseEnterALocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get pleaseEnterALocation;

  /// No description provided for @contactPersonName.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Name'**
  String get contactPersonName;

  /// No description provided for @pleaseEnterAContactName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a contact name'**
  String get pleaseEnterAContactName;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @pleaseEnterAContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a contact number'**
  String get pleaseEnterAContactNumber;

  /// No description provided for @submitJobOfferButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Job Offer'**
  String get submitJobOfferButton;

  /// No description provided for @jobOfferSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Job offer submitted successfully!'**
  String get jobOfferSubmittedSuccessfully;

  /// No description provided for @failedToSubmitJob.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit job'**
  String get failedToSubmitJob;

  /// No description provided for @contactPolice.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get contactPolice;

  /// No description provided for @contactFireBrigade.
  ///
  /// In en, this message translates to:
  /// **'Fire Brigade'**
  String get contactFireBrigade;

  /// No description provided for @contactAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get contactAmbulance;

  /// No description provided for @contactWomensHelpline.
  ///
  /// In en, this message translates to:
  /// **'Women’s Helpline'**
  String get contactWomensHelpline;

  /// No description provided for @contactAasra.
  ///
  /// In en, this message translates to:
  /// **'AASRA (Suicide Prevention)'**
  String get contactAasra;

  /// No description provided for @contactExServicemenWelfare.
  ///
  /// In en, this message translates to:
  /// **'Ex-Servicemen Welfare (ECHS)'**
  String get contactExServicemenWelfare;

  /// No description provided for @contactSeniorCitizenHelpline.
  ///
  /// In en, this message translates to:
  /// **'Senior Citizen Helpline'**
  String get contactSeniorCitizenHelpline;

  /// No description provided for @lawsAndSchemes.
  ///
  /// In en, this message translates to:
  /// **'Laws and Schemes'**
  String get lawsAndSchemes;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
