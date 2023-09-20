import 'package:feelingapp/main.dart';

class ServerSettings {
  String communityManifestLink;
  String privacyDocumentLink;
  String termsLink;
  String faqLink;
  int keepAliveInterval = 10;
  int chatPollingInterval = 10;
  bool _initialized = false;
  int compressionRate = 200;
  String compressionPreset = "fast";
  Map<String, dynamic> shareMessage;
  String shareTitle;
  String minAppVersionThreshold;
  String googleStoreLink;
  String iosStoreLink;


  ServerSettings();

  Future<bool> initialize() async {
    if (_initialized == false) {
      await Future.wait([loadLinks(), loadBehavior()]);
      _initialized = true;
    }
    return true;
  }

  Future<void> loadLinks() async {
    final obj = await dbManager.loadLinks();
    this.communityManifestLink = obj["community_manifest_link"];
    this.privacyDocumentLink = obj["privacy_document_link"];
    this.termsLink = obj["terms_link"];
    this.faqLink = obj["faq_link"];
  }

  Future<void> loadBehavior() async {
    final obj = await dbManager.loadBehavior();
    this.chatPollingInterval = obj["chat_polling_interval"];
    this.keepAliveInterval = obj["keep_alive_interval"];
    this.compressionRate = obj["compression_rate"];
    this.compressionPreset = obj["compression_preset"];
    this.shareTitle = obj["share_title"];
    this.shareMessage = obj["share_message"];
    this.minAppVersionThreshold = obj["min_app_version"];
    this.iosStoreLink = obj["ios_store_link"];
    this.googleStoreLink = obj["google_store_link"];
  }
}
