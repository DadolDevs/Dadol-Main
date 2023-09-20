import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  List<SpecialReward> specials = List.empty(growable: true);
  double subscriptionReward;
  double inviteReward;
  int subscribed;
  double cumulated;
  Reward.fromMap(Map snapshot)
      : subscriptionReward = snapshot['subscriptionReward'] != null
            ? snapshot['subscriptionReward'] + .0
            : 0.0,
        inviteReward = snapshot['inviteReward'] != null
            ? snapshot['inviteReward'] + .0
            : 0.0,
        subscribed = snapshot['subscribed'] ?? 0,
        cumulated =
            snapshot['cumulated'] != null ? snapshot['cumulated'] + .0 : 0.0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscriptionReward'] = this.subscriptionReward;
    data['inviteReward'] = this.inviteReward;
    data['subscribed'] = this.subscribed;
    data['cumulated'] = this.cumulated;
    return data;
  }

  SpecialReward get currentSpecial {
    return specials.firstWhere(
        (element) =>
            element.fromDate.toDate().isBefore(DateTime.now()) &&
            element.toDate.toDate().isAfter(DateTime.now()),
        orElse: () => null);
  }
}

class SpecialReward {
  double subscriptionReward;
  double inviteReward;
  String lottieUrl;
  Timestamp fromDate;
  Timestamp toDate;
  List<SpecialCaption> specialCaptions;

  SpecialReward.fromMap(Map snapshot) {
    subscriptionReward = snapshot['subscriptionReward'] != null
        ? snapshot['subscriptionReward'] + .0
        : 0.0;
    inviteReward =
        snapshot['inviteReward'] != null ? snapshot['inviteReward'] + .0 : 0.0;
    fromDate = snapshot['fromDate'] ?? Timestamp.now();
    toDate = snapshot['toDate'] ?? Timestamp.now();
    lottieUrl = snapshot['lottieUrl'] ?? "";
    specialCaptions = snapshot['specialCaption'] != null
        ? snapshot['specialCaption'].map<SpecialCaption>((cap) {
            return SpecialCaption.fromMap(cap);
          }).toList()
        : List.empty(growable: true);
  }
}

class SpecialCaption {
  String locale;
  String caption;
  SpecialCaption.fromMap(Map snapshot)
      : locale = snapshot['locale'] ?? "it",
        caption = snapshot['caption'] ?? "";
}
