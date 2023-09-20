import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'it'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<AppLocalization>(AppLocalization(locale));
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

class AppLocalization {
  AppLocalization(this.locale);

  Locale locale;

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'nameQuery': 'My name is',
      'birthDateQuery': 'My date of birth is',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'register': 'Sign-up',
      'login': 'Sign-in',
      'googleAccess': "Continue with Google",
      'facebookAccess': "Continue with Facebook",
      'other': "Other",
      'genderQuery': 'I identify myself as',
      'genderPreferenceQuery': 'Show me',
      'privacyCheckbox':
          'I have read and accepted the privacy notice and agreed to the terms of use',
      'describeYourselfWithTags': 'Describe yourself with 6 tags',
      'describeYourselfWithTagsHint': 'Try with funny',
      'askForVideoPresentation': 'Present yourself with a video',
      'askForVideoPresentationSubtitle':
          "Try to be creative and remember that you have only 15 seconds!",
      'record': 'Record',
      'upload': 'Upload',
      'man': 'Man',
      'woman': 'Woman',
      'searchByTag': 'Search tags',
      'reportIssue': 'Report an issue',
      'reportDetails': 'Details',
      'noActivaChats': 'You don\'t have any active chat yet',
      'addNewTag': 'Add new tag',
      'allTagsAddedHint': 'You can change your tags whenever you want',
      'general': 'General',
      'pushNotifications': 'Push notifications',
      'language': 'Language',
      'assistance': 'Assistance',
      'information': 'Information',
      'termsOfService': 'Terms of service',
      'communityManifest': 'Community manifest',
      'privacyInfo': 'Privacy information',
      'account': 'Account',
      'addSocial': 'Add a social profile',
      'accountManagement': 'Account management',
      'exit': 'Exit the app',
      'privacyAndSettings': 'Privacy and settings',
      'errorMailinUse': 'The selected email is already in use.',
      'errorBadInternet':
          "Impossible to reach the remote server. Check if you are online or retry after a while.",
      'errorWrongCredentials': 'User email or user password is incorrect',
      'skip': 'Skip',
      'yesterday': 'Yesterday',
      'today': 'Today',
      'chatMessagePlaceholder': 'NEW MATCH',
      "online": "Online",
      "offline": "Offline",
      "me": "Me",
      "tutorialScroll": "Scroll to watch other videos",
      "tutorialDoubleTap": "Double tap to like",
      "sendReport": "Send report",
      "men": "Men",
      "women": "Women",
      "both": "Both",
      "report1": "Inappropriate Content: offensive or abusive language",
      "report2":
          "Spam: use of Dadol to advertise unrelated products or services",
      "report3": "Fake profile or impersonation",
      "report4":
          "Privacy: inform us if you feel a profile violates a person's privacy",
      "tutorialSingleTap": "Single tap to pause a video",
      "deleteMatch": "Delete match",
      "pushMatch": "New matches",
      "pushMessage": "New messages",
      "pushOther": "Updates",
      "deleteAccount": "Delete account",
      "deleteAccountTitle": "Confirm account deletion",
      "deleteAccountContent":
          "Are you sure you want to delete your account? Once done, this action cannot be reversed",
      "cancel": "Cancel",
      "continue": "Continue",
      "connectGoogle": "Add Google",
      "connectFacebook": "Add Facebook",
      "geolocationEnableTitle": "Please enable location service",
      "geolocationEnableBody":
          "To continue using Dadol you must enable location service",
      "geolocationEnableSuggestionBody":
          "To improve your user experience with Dadol we raccomend you to enable location service",
      "geolocationDeniedForeverBody":
          "Location permissions are permanently denied, we cannot request permissions. Please access the app settings from your phone's system settings to enable them again.",
      "noInternetTitle": "Unable to reach internet",
      "noInternetBody": "Check your internet connection and try again",
      "reportTitle": "Are you sure you want to report this user?",
      "reportBody":
          "We will review the report and any future interaction with this user will be blocked",
      "emptyMatchesPlaceholder1": "Your matches will appear here",
      "emptyMatchesPlaceholder2": "Ops, it seems you don't have any match yet.",
      "attributes": "Attributes",
      "interests": "Interests",
      "searchChatPlaceholder": "Search people",
      "mostPopular": "Most popular",
      "ageNotice": "You must be at least 18 years old to use the app",
      "issueReceived":
          "Thank you!\nA ticket has been opened. You will be shortly contacted by one of our operators.",
      "issueDescription": "Describe your issue",
      "edit": "Edit",
      "share": "Share",
      "settings": "Settings",
      "recordRegisterHint": "Record/upload your video.",
      "personalSettings": "Personal settings",
      "forgotPassowrd": "Forgot password",
      "resetPassowrd": "Reset password",
      "backToLogin": "Back to login",
      "waitForUpload":
          "Your video is being uploaded. Please don't close the app while the upload badge is active. Once finished, your video will be approved in 24 hours.",
      "tellusabout": "Tell us about yourself",
      "telltags": "Choose your tags",
      "touchIcons": "Touch the icons for a complete list of tags.",
      "golikesomeone": "Like some videos on the homepage and check your luck",
      "suspendAccount": "Suspend account",
      "suspendPopup":
          "Are you sure you want to suspend your account? You will not appear in searches and will not be able to send and receive new messages until you login again.",
      "suspendAccountTitle": "Confirm account suspension",
      "wellcomeBack": "Welcome back",
      "missedyou": "we missed you!",
      "viewLimitReached":
          "Were you having fun? Unfortunately, you have exceeded your daily viewing limit. Check back tomorrow for more videos.",
      "uploadVideoToContinue":
          "To continue using Dadol please upload your video in the profile section.",
      "noMoreVids":
          "We don't have any more videos to show. Come later for new videos.",
      "issueTitleConfirmation": "Are you sure you want to report this issue?",
      "issueBodyConfirmation":
          "We will analyze your issue and you will be contacted by the Dadol team shortly.",
      "tutorialTitle": "Let's take a brief tour of Dadol",
      "tutorialFinalRemark1":
          "We show you only the users that are close to you",
      "tutorialFinalRemark2":
          "We accurately filter the users based on your age",
      "confirmUnmachTitle": "Delete match?",
      "confirmUnmachBody":
          "The chat will be deleted and you will not be able to talk with this person anymore",
      "explainWhy": "Please explain why: ",
      "deleteReason1": "I met somebody thanks to Dadol",
      "deleteReason2": "I met somebody outside of Dadol",
      "deleteReason3": "Few new profiles",
      "deleteReason4": "Few matches",
      "deleteReason5": "I don't like the videos of other users",
      "deleteReason6": "I don't like the app",
      "deleteReason7": "Other",
      "subject": "Subject: ",
      "backToHome": "No, go back to home",
      "goToProfile": "Yes, go to profile page",
      "uploadVideoToContinueTitle":
          "To interact with other users you must first complete your profile",
      "uploadVideoToContinueSubTitle": "Ready?",
      "loginWithApple": "Continue with Apple",
      "reportUser": "Report content",
      "newVersionTitle": "A new version of the app is available",
      "newVersionBody": "To continue using Dadol you need to update the app.",
      "tagListButtonTutorial": "Click here for a complete list of all tags",
      "tagListTutorial":
          "You can scroll and select the tags that represent you the most",
      'profileCompleted':
          "Congratulations, you have completed your profile. \nll Dadol team will approve your video within 24 hours. \n In the meantime you can watch other users' videos.",
      'okCompleted': "Back to the App",
      'videoRefusedTitle': "We're very sorry.",
      'videoRefusedBody': "Your video was rejected because it doesn't meet community standards.",
      'videoAcceptedTitle': "Congratulations!",
      'videoAcceptedBody': "Your video has been approved. You have unlocked all the features of Dadol! Have fun!",
      'refusedMoreInfo':
      "Click here to get more info",
      'inviteHeader':"Share your promo code and get [[inviteReward]] Dadol Coins for each friend who uploads a video approved by the staff. In the future you will be able to use Dadol Coins for new features we are working on!",
      'invite':"Invite",
      'checkoutAmz':"Checkout",
      'subscribedFriends':"Subscribed",
      'amznBonus':"Dadol Coin",
      'shareCaption':"I'm waiting for you on Dadol, the first social dating app based only on video profiles! \nUse my promo code to immediately receive a [[subscriptionReward]] Dadol Coin",
      'shareDroid':"https://play.google.com/store/apps/details?id=it.dadol.dadolapp",
      'shareiOS':"https://apps.apple.com/it/app/dadol/id1561013090",
      'promoCode':"Promo Code",
      'noCode':"I don't have a code.",
      'friends':"Friends",
      'copiedToClipboard':"Copied to clipboard.",
      'validationCodeRequired':"Now enter the validation code you received.",
      'processing':"processing...",
      'askCodeHeader':"PROMO CODE (optional)",
      'inputRewardMail':"one last step...\nTell us the mail where you want the coupon to be delivered!",
      'askCodeCaption':"Enter a promo code to immediately get a [[subscriptionReward]] Dadol Coins.",
      'youEntitled':"Your entitled to an Amazon Gift card of: ",
      'missingVideo':"In order to get the vouchers you need an accepted video.",
      'uploadNewVideo':"Upload a new video!",
      'missingPhone':"We'll need to verify your phone number in order to send the Amazon Gift.",
      'minGiftRequired':"You must have at least €5 credit to redeem the Amazon voucher. Invite other friends to Dadol and get a €[[inviteReward]] credit for each video that is approved.",
      'couponSentTitle':"Amazon coupon sent!",
      'couponSentBody':"You're going to receive an email with the requested amazon coupon!",
      'rewardInfoTitle':"Share with friends.",
      'rewardInfoBody':"Go to the Invite page and share your Promo Code to get Dadol Coins.",
  'smsNotValid':"The code is not valid.",
  'phoneNotValid':"This phone number is already in use.",
      'phoneValid':"Your phone number has been accepted.",
      'badgeVideoOK':"Video approved",
      'badgeVideoRefused':"Video refused",
      'sendCode':"Send Code",
      'badgeVideoError':"Video in Error (upload)",
      'badgeVideoPending':"Video in approval",
      'badgeVideoMissing':"Upload a Video",
      'couponProcessing':"We are processing your request, within 72 hours we will send you the voucher to the email address you provided",
      'ops':"Ops",
  'phoneCaptionSub':"Help us verify you're a real person, Dadol highly values safety."
    },
    'it': {
      'nameQuery': 'Mi chiamo',
      'birthDateQuery': 'Sono nata/o',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Conferma Password',
      'register': 'Registrati',
      'login': 'Accedi',
      'googleAccess': "Accedi con Google",
      'facebookAccess': "Accedi con Facebook",
      'other': "Altro",
      'genderQuery': 'Mi identifico come',
      'genderPreferenceQuery': 'Mostrami',
      'privacyCheckbox':
          "Ho letto e accettato l'informativa sulla privacy e i termini e le condizioni",
      'describeYourselfWithTags': 'Descriviti in 6 tag',
      'describeYourselfWithTagsHint': 'Prova con simpatico',
      'askForVideoPresentation': 'Presentati con un video',
      'askForVideoPresentationSubtitle':
          "Cerca di essere creativo e ricordati: hai solo 15 secondi!",
      'record': 'Registra',
      'upload': 'Carica',
      'man': 'Uomo',
      'woman': 'Donna',
      'searchByTag': 'Cerca tag',
      'reportIssue': 'Segnalaci un problema',
      'reportDetails': 'Note',
      'noActivaChats': 'Per ora non hai nessuna chat attiva',
      'addNewTag': 'Aggiungi nuovo tag',
      'allTagsAddedHint': 'Puoi cambiare i tuoi tag quando vuoi',
      'general': 'Generale',
      'pushNotifications': 'Notifiche push',
      'language': 'Lingua',
      'assistance': 'Assistenza',
      'information': 'Informazioni',
      'termsOfService': 'Termini di utilizzo',
      'communityManifest': 'Manifesto della community',
      'privacyInfo': 'Informazioni sulla privacy',
      'account': 'Account',
      'addSocial': 'Collega account social',
      'accountManagement': 'Gestione account',
      'exit': 'Esci dall\'app',
      'privacyAndSettings': 'Impostazioni e privacy',
      'errorMailinUse': 'Esiste già un account con la stessa email',
      'errorBadInternet':
          "Impossibile collegarsi ad Internet. Controlla le tue impostazioni o riprova più tardi.",
      'errorWrongCredentials': 'Email o password non corrette.',
      'skip': 'Salta',
      'yesterday': 'Ieri',
      'today': 'Oggi',
      'chatMessagePlaceholder': 'NUOVA AFFINITA\'',
      "online": "Online",
      "offline": "Offline",
      "me": "Me",
      "tutorialScroll": "Scroll per vedere altri video",
      "tutorialDoubleTap": "Doppio Tap per like",
      "sendReport": "Invia una segnalazione",
      "men": "Uomini",
      "women": "Donne",
      "both": "Entrambi",
      "report1": "Contenuto inappropriato: abuso o linguaggio offensivo",
      "report2":
          "Spam: uso di Dadol per pubblicità a prodotti o servizi esterni",
      "report3": "Profilo fake o sostituzione di persona",
      "report4":
          "Privacy: informaci se qualcuno sta violando la tua privacy o quella degli altri",
      "tutorialSingleTap": "Tap singolo per mettere in pausa",
      "deleteMatch": "Annulla affinità",
      "pushMatch": "Nuove affinità",
      "pushMessage": "Nuovi messaggi",
      "pushOther": "Aggiornamenti",
      "deleteAccount": "Elimina account",
      "deleteAccountTitle": "Conferma eliminazione account",
      "deleteAccountContent":
          "Sei sicuro di voler cancellare il tuo account? Una volta fatto l'account non potrà più essere recuperato",
      "cancel": "Annulla",
      "continue": "Continua",
      "connectGoogle": "Aggiungi Google",
      "connectFacebook": "Aggiungi Facebook",
      "geolocationEnableTitle": "Attiva il servizio di geolocalizzazione.",
      "geolocationEnableBody":
          "Per continuare ad usare Dadol ti chiediamo di attivare il servizio di geolocalizzazione.",
      "geolocationEnableSuggestionBody":
          "Per migliorare la tua esperienza d'utilizzo ti raccomandiamo di accendere il servizio di geolocalizzazione.",
      "geolocationDeniedForeverBody":
          "L'accesso alla geolocalizzazione è stato disattivato per Dadol. Accedi alle proprietà dell'app dalle impostazioni del sistema per attivarlo",
      "noInternetTitle": "Impossibile accedere a internet",
      "noInternetBody": "Controlla le tue impostazioni internet e riprova",
      "reportTitle": "Sei sicuro di voler segnalare questa persona?",
      "reportBody":
          "Analizzeremo la tua segnalazione e ogni interazione futura con questa persona verrà bloccata",
      "emptyMatchesPlaceholder1": "Le tue affinità compariranno qui",
      "emptyMatchesPlaceholder2":
          "Ops, sembra che tu non abbia ancora ricevuto delle affinità",
      "attributes": "Personalità",
      "interests": "Interessi",
      "searchChatPlaceholder": "Cerca tra le affinità",
      "mostPopular": "Più popolari",
      "ageNotice": "Devi essere maggiorenne per usare Dadol",
      "issueReceived":
          "Grazie!\nLa tua segnalazione è stata inviata. In poco tempo il team di Dadol ti risponderà nella Chat",
      "issueDescription": "Descrivi il tuo problema",
      "edit": "Modifica",
      "share": "Condividi",
      "settings": "Impostazioni",
      "recordRegisterHint": "Carica/registra il tuo video.",
      "personalSettings": "Impostazioni personali",
      "forgotPassowrd": "Password dimenticata",
      "resetPassowrd": "Reset password",
      "backToLogin": "Torna al login",
      "waitForUpload":
          "Stiamo caricando il tuo video. Non chiudere l'app finchè l'icona dell'upload è attiva. Una volta completato il caricamento approveremo il tuo video nell'arco di 24h",
      "tellusabout": "Raccontaci di te",
      "telltags": "Scegli i tuoi tag",
      "touchIcons": "Tocca le icone per la lista completa dei tags.",
      "golikesomeone":
          "Guarda i video nella Homepage e metti like a quelli che ti piacciono",
      "suspendAccount": "Sospendi account",
      "suspendPopup":
          "Sei sicuro di voler sospendere il tuo account? Non comparirai più nelle ricerche e non potrai chattare finchè non effettuerai nuovamente l'accesso.",
      "suspendAccountTitle": "Conferma sospensione account",
      "wellcomeBack": "Bentornato",
      "missedyou": "ci sei mancato!",
      "viewLimitReached":
          "Ti stavi divertendo? Purtroppo hai superato il limite di visualizzazione giornaliero. Torna domani per vedere altri video.",
      "uploadVideoToContinue":
          "Per continuare ad utilizzare Dadol carica il tuo video nella sezione profilo.",
      "noMoreVids":
          "Non abbiamo più video da mostrarti. Ritorna dopo per nuovi video.",
      "issueTitleConfirmation":
          "Sei sicuro di voler mandare questa segnalazione?",
      "issueBodyConfirmation":
          "Analizzeremo la tua segnalazione e verrai contattato dal team di Dadol.",
      "tutorialTitle": "Eccoti un breve tour di Dadol",
      "tutorialFinalRemark1":
          "Ti facciamo vedere solo gli utenti che sono vicino a te",
      "tutorialFinalRemark2":
          "Selezioniamo utenti che sono compatibili con la tua età",
      "confirmUnmachTitle": "Annullare l'affinità?",
      "confirmUnmachBody":
          "La chat verrà cancellata e non potrai più chattare con questa persona.",
      "explainWhy": "Spiegaci meglio: ",
      "deleteReason1": "Ho incontrato qualcuno grazie a Dadol",
      "deleteReason2": "Ho incontrato qualcuno fuori da Dadol",
      "deleteReason3": "Pochi nuovi profili",
      "deleteReason4": "Poche affinità",
      "deleteReason5": "Non mi piacciono i video degli altri utenti",
      "deleteReason6": "Non mi piace l'app",
      "deleteReason7": "Altro",
      "subject": "Oggetto: ",
      "backToHome": "No, torna nella Homepage",
      "goToProfile": "Si, vai nella pagina profilo",
      "uploadVideoToContinueTitle":
          "Per interagire con gli altri utenti dovresti prima completare il tuo profilo",
      "uploadVideoToContinueSubTitle": "Sei pronto?",
      "loginWithApple": "Accedi con Apple",
      "reportUser": "Segnala contenuto",
      "newVersionTitle": "Una nuova versione dell'app è disponibile",
      "newVersionBody": "Per continuare devi aggiornare l'app sullo store",
      "tagListButtonTutorial":
          "Clicca qui per visualizzare la lista completa dei tag",
      "tagListTutorial":
          "Puoi scorrere e selezionare i tag che ti rappresentano di più",
      'profileCompleted':
          "Congratulazioni, hai completato il tuo profilo.\nIl team di Dadol approverà il tuo video entro 24 ore.\nNel frattempo puoi guardare i video degli altri utenti.",
      'okCompleted': "Torna all'App",
      'videoRefusedTitle': "Ci dispiace molto.",
      'videoRefusedBody':
          "Il tuo video è stato rifiutato perché non rispetta gli standard della community.",
      'videoAcceptedTitle': "Complimenti!",
      'videoAcceptedBody':
          "Il tuo video è stato approvato. Hai sbloccato tutte le funzionalità di Dadol! Buon divertimento!",
      'refusedMoreInfo':
      "Clicca qui per maggiori info",
      'inviteHeader':"Condividi il tuo codice promo ed ottieni [[inviteReward]] Dadol Coin per ogni amic* che caricherà un video approvato dallo staff. In futuro potrai utilizzare i Dadol Coin per nuove features su cui stiamo lavorando!",
      'invite':"Invita",
      'checkoutAmz':"Riscatta Buono",
      'subscribedFriends':"Iscritti",
      'amznBonus':"Dadol Coin",
      'shareDroid':"https://play.google.com/store/apps/details?id=it.dadol.dadolapp",
      'shareiOS':"https://apps.apple.com/it/app/dadol/id1561013090",
      'shareCaption':"Ti aspetto su Dadol, la prima social dating app basata solo su video profili! Usa il mio codice promo per ricevere subito [[subscriptionReward]] Dadol Coins",
      'promoCode':"Promo Code",
      'noCode':"Non possiedo un codice.",
      'youEntitled':"Hai diritto ad un buono Amazon del valore di: ",
      'friends':"Amici",
      'validationCodeRequired':"Ora inserisci il codice ricevuto via SMS.",
      'copiedToClipboard':"Copiato negli appunti.",
      'missingVideo':"Per riscattare i buoni amazon è necessario aver caricato un video approvato dallo staff.",
      'processing':"in lavorazione...",
      'missingPhone':"Verifica il tuo numero di cellulare per ricevere il buono Amazon.",
      'askCodeHeader':"CODICE PROMO (facoltativo)",
      'inputRewardMail':"un ultimo passo...\nInserisci la mail a cui recapiteremo il buono!",
      'askCodeCaption':"Inserisci un codice promo per ottenere subito un buono [[subscriptionReward]] Dadol Coins.",
      'uploadNewVideo':"Carica un nuovo video!",
      'minGiftRequired':"Devi avere almeno un credito di 5€ per riscattare il buono Amazon.  Invita altri amici su Dadol ed ottieni un credito di [[inviteReward]]€ per ogni video che viene approvato.",
      'couponSentTitle':"Buono Amazon inviato!",
      'couponSentBody':"A breve riceverai una mail contenente il buono amazon da te richiesto.",
      'rewardInfoTitle':"Invita gli Amici.",
      'rewardInfoBody':"Accedi alla pagina Invita e condividi il tuo Promo Code per ottenere Dadol Coin.",
      'smsNotValid':"Il codice inserito non è corretto.",
      'phoneNotValid':"Il numero inserito è già in uso.",
      'phoneValid':"Il numero di telefono è stato accettato.",
      'badgeVideoOK':"Video Approvato",
      'badgeVideoRefused':"Video rifiutato",
      'badgeVideoError':"Video in Errore (ricaricare)",
      'badgeVideoMissing':"Video da Caricare",
      'badgeVideoPending':"Video in approvazione",
      'sendCode':"Invia Codice",
      'couponProcessing':"Stiamo processando la tua richiesta, entro 72 ore ti invieremo il buono all'indirizzo specificato",
      'ops':"Ops",
      'phoneCaptionSub':"Aiutaci a verificare che tu sia una persona reale, su Dadol la sicurezza è molto importante"
    },
  };

  String get badgeVideoOK {
    return _localizedValues[locale.languageCode]['badgeVideoOK'];
  }
  String get phoneCaptionSub {
    return _localizedValues[locale.languageCode]['phoneCaptionSub'];
  }
  String get sendCode {
    return _localizedValues[locale.languageCode]['sendCode'];
  }

  String get phoneValid {
    return _localizedValues[locale.languageCode]['phoneValid'];
  }
  String get badgeVideoPending {
    return _localizedValues[locale.languageCode]['badgeVideoPending'];
  }

  String get badgeVideoRefused {
    return _localizedValues[locale.languageCode]['badgeVideoRefused'];
  }

  String get badgeVideoMissing {
    return _localizedValues[locale.languageCode]['badgeVideoMissing'];
  }

  String get badgeVideoError {
    return _localizedValues[locale.languageCode]['badgeVideoError'];
  }

  String get ops {
    return _localizedValues[locale.languageCode]['ops'];
  }

  String get couponProcessing {
    return _localizedValues[locale.languageCode]['couponProcessing'];
  }

  String get smsNotValid {
    return _localizedValues[locale.languageCode]['smsNotValid'];
  }

  String get phoneNotValid {
    return _localizedValues[locale.languageCode]['phoneNotValid'];
  }

  String get rewardInfoTitle {
    return _localizedValues[locale.languageCode]['rewardInfoTitle'];
  }

  String get rewardInfoBody {
    return _localizedValues[locale.languageCode]['rewardInfoBody'];
  }

  String get couponSentTitle {
    return _localizedValues[locale.languageCode]['couponSentTitle'];
  }

  String get couponSentBody {
    return _localizedValues[locale.languageCode]['couponSentBody'];
  }

  String get inputRewardMail {
    return _localizedValues[locale.languageCode]['inputRewardMail'];
  }

  String get shareCaption {
    return _localizedValues[locale.languageCode]['shareCaption'];
  }

  String get askCodeHeader {
    return _localizedValues[locale.languageCode]['askCodeHeader'];
  }

  String get askCodeCaption {
    return _localizedValues[locale.languageCode]['askCodeCaption'];
  }

  String get missingPhone {
    return _localizedValues[locale.languageCode]['missingPhone'];
  }

  String get validationCodeRequired {
    return _localizedValues[locale.languageCode]['validationCodeRequired'];
  }

  String get processing {
    return _localizedValues[locale.languageCode]['processing'];
  }

  String get youEntitled {
    return _localizedValues[locale.languageCode]['youEntitled'];
  }

  String get minGiftRequired {
    return _localizedValues[locale.languageCode]['minGiftRequired'];
  }

  String get noCode {
    return _localizedValues[locale.languageCode]['noCode'];
  }

  String get copiedToClipboard {
    return _localizedValues[locale.languageCode]['copiedToClipboard'];
  }

  String get missingVideo {
    return _localizedValues[locale.languageCode]['missingVideo'];
  }

  String get promoCode {
    return _localizedValues[locale.languageCode]['promoCode'];
  }

  String get shareDroid {
    return _localizedValues[locale.languageCode]['shareDroid'];
  }

  String get shareiOS {
    return _localizedValues[locale.languageCode]['shareiOS'];
  }

  String get inviteHeader {
    return _localizedValues[locale.languageCode]['inviteHeader'];
  }

  String get invite {
    return _localizedValues[locale.languageCode]['invite'];
  }

  String get checkoutAmz {
    return _localizedValues[locale.languageCode]['checkoutAmz'];
  }

  String get subscribedFriends {
    return _localizedValues[locale.languageCode]['subscribedFriends'];
  }

  String get friends {
    return _localizedValues[locale.languageCode]['friends'];
  }

  String get amznBonus {
    return _localizedValues[locale.languageCode]['amznBonus'];
  }

  String get videoRefusedTitle {
    return _localizedValues[locale.languageCode]['videoRefusedTitle'];
  }

  String get videoRefusedBody {
    return _localizedValues[locale.languageCode]['videoRefusedBody'];
  }

  String get videoAcceptedTitle {
    return _localizedValues[locale.languageCode]['videoAcceptedTitle'];
  }

  String get videoAcceptedBody {
    return _localizedValues[locale.languageCode]['videoAcceptedBody'];
  }

  String get profileCompleted {
    return _localizedValues[locale.languageCode]['profileCompleted'];
  }

  String get okCompleted {
    return _localizedValues[locale.languageCode]['okCompleted'];
  }

  String get uploadNewVideo {
    return _localizedValues[locale.languageCode]['uploadNewVideo'];
  }

  String get refusedMoreInfo {
    return _localizedValues[locale.languageCode]['refusedMoreInfo'];
  }

  String get newVersionBody {
    return _localizedValues[locale.languageCode]['newVersionBody'];
  }

  String get newVersionTitle {
    return _localizedValues[locale.languageCode]['newVersionTitle'];
  }

  String get reportUser {
    return _localizedValues[locale.languageCode]['reportUser'];
  }

  String get loginWithApple {
    return _localizedValues[locale.languageCode]['loginWithApple'];
  }

  String get uploadVideoToContinueSubTitle {
    return _localizedValues[locale.languageCode]
        ['uploadVideoToContinueSubTitle'];
  }

  String get uploadVideoToContinueTitle {
    return _localizedValues[locale.languageCode]['uploadVideoToContinueTitle'];
  }

  String get goToProfile {
    return _localizedValues[locale.languageCode]['goToProfile'];
  }

  String get backToHome {
    return _localizedValues[locale.languageCode]['backToHome'];
  }

  String get subject {
    return _localizedValues[locale.languageCode]['subject'];
  }

  String get deleteReason1 {
    return _localizedValues[locale.languageCode]['deleteReason1'];
  }

  String get deleteReason2 {
    return _localizedValues[locale.languageCode]['deleteReason2'];
  }

  String get deleteReason3 {
    return _localizedValues[locale.languageCode]['deleteReason3'];
  }

  String get deleteReason4 {
    return _localizedValues[locale.languageCode]['deleteReason4'];
  }

  String get deleteReason5 {
    return _localizedValues[locale.languageCode]['deleteReason5'];
  }

  String get deleteReason6 {
    return _localizedValues[locale.languageCode]['deleteReason6'];
  }

  String get deleteReason7 {
    return _localizedValues[locale.languageCode]['deleteReason7'];
  }

  String get explainWhy {
    return _localizedValues[locale.languageCode]['explainWhy'];
  }

  String get confirmUnmachBody {
    return _localizedValues[locale.languageCode]['confirmUnmachBody'];
  }

  String get confirmUnmachTitle {
    return _localizedValues[locale.languageCode]['confirmUnmachTitle'];
  }

  String get tutorialFinalRemark2 {
    return _localizedValues[locale.languageCode]['tutorialFinalRemark2'];
  }

  String get tutorialFinalRemark1 {
    return _localizedValues[locale.languageCode]['tutorialFinalRemark1'];
  }

  String get touchIcons {
    return _localizedValues[locale.languageCode]['touchIcons'];
  }

  String get tutorialTitle {
    return _localizedValues[locale.languageCode]['tutorialTitle'];
  }

  String get issueTitleConfirmation {
    return _localizedValues[locale.languageCode]['issueTitleConfirmation'];
  }

  String get issueBodyConfirmation {
    return _localizedValues[locale.languageCode]['issueBodyConfirmation'];
  }

  String get noMoreVids {
    return _localizedValues[locale.languageCode]['noMoreVids'];
  }

  String get viewLimitReached {
    return _localizedValues[locale.languageCode]['viewLimitReached'];
  }

  String get uploadVideoToContinue {
    return _localizedValues[locale.languageCode]['uploadVideoToContinue'];
  }

  String get missedyou {
    return _localizedValues[locale.languageCode]['missedyou'];
  }

  String get wellcomeBack {
    return _localizedValues[locale.languageCode]['wellcomeBack'];
  }

  String get suspendAccountTitle {
    return _localizedValues[locale.languageCode]['suspendAccountTitle'];
  }

  String get suspendPopup {
    return _localizedValues[locale.languageCode]['suspendPopup'];
  }

  String get suspendAccount {
    return _localizedValues[locale.languageCode]['suspendAccount'];
  }

  String get golikesomeone {
    return _localizedValues[locale.languageCode]['golikesomeone'];
  }

  String get tellusabout {
    return _localizedValues[locale.languageCode]['tellusabout'];
  }

  String get telltags {
    return _localizedValues[locale.languageCode]['telltags'];
  }

  String get waitForUpload {
    return _localizedValues[locale.languageCode]['waitForUpload'];
  }

  String get forgotPassowrd {
    return _localizedValues[locale.languageCode]['forgotPassowrd'];
  }

  String get resetPassowrd {
    return _localizedValues[locale.languageCode]['resetPassowrd'];
  }

  String get backToLogin {
    return _localizedValues[locale.languageCode]['backToLogin'];
  }

  String get personalSettings {
    return _localizedValues[locale.languageCode]['personalSettings'];
  }

  String get recordRegisterHint {
    return _localizedValues[locale.languageCode]['recordRegisterHint'];
  }

  String get edit {
    return _localizedValues[locale.languageCode]['edit'];
  }

  String get share {
    return _localizedValues[locale.languageCode]['share'];
  }

  String get settings {
    return _localizedValues[locale.languageCode]['settings'];
  }

  String get issueDescription {
    return _localizedValues[locale.languageCode]['issueDescription'];
  }

  String get issueReceived {
    return _localizedValues[locale.languageCode]['issueReceived'];
  }

  String get ageNotice {
    return _localizedValues[locale.languageCode]['ageNotice'];
  }

  String get mostPopular {
    return _localizedValues[locale.languageCode]['mostPopular'];
  }

  String get searchChatPlaceholder {
    return _localizedValues[locale.languageCode]['searchChatPlaceholder'];
  }

  String get attributes {
    return _localizedValues[locale.languageCode]['attributes'];
  }

  String get interests {
    return _localizedValues[locale.languageCode]['interests'];
  }

  String get emptyMatchesPlaceholder1 {
    return _localizedValues[locale.languageCode]['emptyMatchesPlaceholder1'];
  }

  String get emptyMatchesPlaceholder2 {
    return _localizedValues[locale.languageCode]['emptyMatchesPlaceholder2'];
  }

  String get reportTitle {
    return _localizedValues[locale.languageCode]['reportTitle'];
  }

  String get reportBody {
    return _localizedValues[locale.languageCode]['reportBody'];
  }

  String get noInternetTitle {
    return _localizedValues[locale.languageCode]['noInternetTitle'];
  }

  String get noInternetBody {
    return _localizedValues[locale.languageCode]['noInternetBody'];
  }

  String get geolocationDeniedForeverBody {
    return _localizedValues[locale.languageCode]
        ['geolocationDeniedForeverBody'];
  }

  String get geolocationEnableSuggestionBody {
    return _localizedValues[locale.languageCode]
        ['geolocationEnableSuggestionBody'];
  }

  String get geolocationEnableTitle {
    return _localizedValues[locale.languageCode]['geolocationEnableTitle'];
  }

  String get geolocationEnableBody {
    return _localizedValues[locale.languageCode]['geolocationEnableBody'];
  }

  String get connectGoogle {
    return _localizedValues[locale.languageCode]['connectGoogle'];
  }

  String get connectFacebook {
    return _localizedValues[locale.languageCode]['connectFacebook'];
  }

  String get continue_ {
    return _localizedValues[locale.languageCode]['continue'];
  }

  String get cancel {
    return _localizedValues[locale.languageCode]['cancel'];
  }

  String get deleteAccountContent {
    return _localizedValues[locale.languageCode]['deleteAccountContent'];
  }

  String get deleteAccountTitle {
    return _localizedValues[locale.languageCode]['deleteAccountTitle'];
  }

  String get deleteAccount {
    return _localizedValues[locale.languageCode]['deleteAccount'];
  }

  String get pushMatch {
    return _localizedValues[locale.languageCode]['pushMatch'];
  }

  String get pushMessage {
    return _localizedValues[locale.languageCode]['pushMessage'];
  }

  String get pushOther {
    return _localizedValues[locale.languageCode]['pushOther'];
  }

  String get deleteMatch {
    return _localizedValues[locale.languageCode]['deleteMatch'];
  }

  String get tutorialSingleTap {
    return _localizedValues[locale.languageCode]['tutorialSingleTap'];
  }

  String get report4 {
    return _localizedValues[locale.languageCode]['report4'];
  }

  String get report3 {
    return _localizedValues[locale.languageCode]['report3'];
  }

  String get report2 {
    return _localizedValues[locale.languageCode]['report2'];
  }

  String get report1 {
    return _localizedValues[locale.languageCode]['report1'];
  }

  String get both {
    return _localizedValues[locale.languageCode]['both'];
  }

  String get women {
    return _localizedValues[locale.languageCode]['women'];
  }

  String get men {
    return _localizedValues[locale.languageCode]['men'];
  }

  String get sendReport {
    return _localizedValues[locale.languageCode]['sendReport'];
  }

  String get tutorialScroll {
    return _localizedValues[locale.languageCode]['tutorialScroll'];
  }

  String get tutorialDoubleTap {
    return _localizedValues[locale.languageCode]['tutorialDoubleTap'];
  }

  String get me {
    return _localizedValues[locale.languageCode]['me'];
  }

  String get online {
    return _localizedValues[locale.languageCode]['online'];
  }

  String get offline {
    return _localizedValues[locale.languageCode]['offline'];
  }

  String get chatMessagePlaceholder {
    return _localizedValues[locale.languageCode]['chatMessagePlaceholder'];
  }

  String get yesterday {
    return _localizedValues[locale.languageCode]['yesterday'];
  }

  String get today {
    return _localizedValues[locale.languageCode]['today'];
  }

  String get skip {
    return _localizedValues[locale.languageCode]['skip'];
  }

  String get errorMailinUse {
    return _localizedValues[locale.languageCode]['errorMailinUse'];
  }

  String get errorWrongCredentials {
    return _localizedValues[locale.languageCode]['errorWrongCredentials'];
  }

  String get errorBadInternet {
    return _localizedValues[locale.languageCode]['errorBadInternet'];
  }

  String get privacyAndSettings {
    return _localizedValues[locale.languageCode]['privacyAndSettings'];
  }

  String get general {
    return _localizedValues[locale.languageCode]['general'];
  }

  String get pushNotifications {
    return _localizedValues[locale.languageCode]['pushNotifications'];
  }

  String get language {
    return _localizedValues[locale.languageCode]['language'];
  }

  String get assistance {
    return _localizedValues[locale.languageCode]['assistance'];
  }

  String get information {
    return _localizedValues[locale.languageCode]['information'];
  }

  String get termsOfService {
    return _localizedValues[locale.languageCode]['termsOfService'];
  }

  String get communityManifest {
    return _localizedValues[locale.languageCode]['communityManifest'];
  }

  String get privacyInfo {
    return _localizedValues[locale.languageCode]['privacyInfo'];
  }

  String get account {
    return _localizedValues[locale.languageCode]['account'];
  }

  String get addSocial {
    return _localizedValues[locale.languageCode]['addSocial'];
  }

  String get accountManagement {
    return _localizedValues[locale.languageCode]['accountManagement'];
  }

  String get exit {
    return _localizedValues[locale.languageCode]['exit'];
  }

  String get allTagsAddedHint {
    return _localizedValues[locale.languageCode]['allTagsAddedHint'];
  }

  String get addNewTag {
    return _localizedValues[locale.languageCode]['addNewTag'];
  }

  String get noActivaChats {
    return _localizedValues[locale.languageCode]['noActivaChats'];
  }

  String get reportIssue {
    return _localizedValues[locale.languageCode]['reportIssue'];
  }

  String get reportDetails {
    return _localizedValues[locale.languageCode]['reportDetails'];
  }

  String get searchByTag {
    return _localizedValues[locale.languageCode]['searchByTag'];
  }

  String get tagListButtonTutorial {
    return _localizedValues[locale.languageCode]['tagListButtonTutorial'];
  }

  String get tagListTutorial {
    return _localizedValues[locale.languageCode]['tagListTutorial'];
  }

  String get man {
    return _localizedValues[locale.languageCode]['man'];
  }

  String get woman {
    return _localizedValues[locale.languageCode]['woman'];
  }

  String get askForVideoPresentation {
    return _localizedValues[locale.languageCode]['askForVideoPresentation'];
  }

  String get askForVideoPresentationSubtitle {
    return _localizedValues[locale.languageCode]
        ['askForVideoPresentationSubtitle'];
  }

  String get record {
    return _localizedValues[locale.languageCode]['record'];
  }

  String get upload {
    return _localizedValues[locale.languageCode]['upload'];
  }

  String get describeYourselfWithTags {
    return _localizedValues[locale.languageCode]['describeYourselfWithTags'];
  }

  String get describeYourselfWithTagsHint {
    return _localizedValues[locale.languageCode]
        ['describeYourselfWithTagsHint'];
  }

  String get genderQuery {
    return _localizedValues[locale.languageCode]['genderQuery'];
  }

  String get genderPreferenceQuery {
    return _localizedValues[locale.languageCode]['genderPreferenceQuery'];
  }

  String get privacyCheckbox {
    return _localizedValues[locale.languageCode]['privacyCheckbox'];
  }

  String get googleAccess {
    return _localizedValues[locale.languageCode]['googleAccess'];
  }

  String get facebookAccess {
    return _localizedValues[locale.languageCode]['facebookAccess'];
  }

  String get other {
    return _localizedValues[locale.languageCode]['other'];
  }

  String get register {
    return _localizedValues[locale.languageCode]['register'];
  }

  String get login {
    return _localizedValues[locale.languageCode]['login'];
  }

  String get confirmPassword {
    return _localizedValues[locale.languageCode]['confirmPassword'];
  }

  String get email {
    return _localizedValues[locale.languageCode]['email'];
  }

  String get password {
    return _localizedValues[locale.languageCode]['password'];
  }

  String get nameQuery {
    return _localizedValues[locale.languageCode]['nameQuery'];
  }

  String get birthDateQuery {
    return _localizedValues[locale.languageCode]['birthDateQuery'];
  }
}
