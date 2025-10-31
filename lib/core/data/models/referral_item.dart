class ReferralItem {
  final String id;
  final String inviterId;
  final String inviteeId;
  final String bonusStatus;
  final String? bonusPaidAt;
  final String createdAt;
  final String updatedAt;
  final Invitee invitee;

  ReferralItem({
    required this.id,
    required this.inviterId,
    required this.inviteeId,
    required this.bonusStatus,
    this.bonusPaidAt,
    required this.createdAt,
    required this.updatedAt,
    required this.invitee,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) {
    return ReferralItem(
      id: json['id'] ?? '',
      inviterId: json['inviterId'] ?? '',
      inviteeId: json['inviteeId'] ?? '',
      bonusStatus: json['bonusStatus'] ?? '',
      bonusPaidAt: json['bonusPaidAt'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      invitee: Invitee.fromJson(json['invitee'] ?? {}),
    );
  }

  String get name => '${invitee.firstName} ${invitee.lastName}';
  String get dateJoined => createdAt;
  String get reward => bonusPaidAt ?? 'N/A';
  String get status => bonusStatus;
}

class Invitee {
  final String id;
  final String firstName;
  final String email;
  final String lastName;

  Invitee({
    required this.id,
    required this.firstName,
    required this.email,
    required this.lastName,
  });

  factory Invitee.fromJson(Map<String, dynamic> json) {
    return Invitee(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }
}