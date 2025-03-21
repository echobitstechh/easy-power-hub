import 'package:easyph/core/data/models/product.dart';
import 'package:easyph/core/data/models/profile.dart';

import 'order_item.dart';

class RaffleTicket {
  String? id;
  Profile? user;
  Raffle? raffle;
  String? order;
  String? status;
  String? ticketNumber;
  bool? isWinner;
  String? createdAt;
  String? updatedAt;

  RaffleTicket({
    this.id,
    this.user,
    this.raffle,
    this.order,
    this.status,
    this.ticketNumber,
    this.isWinner,
    this.createdAt,
    this.updatedAt,
  });

  RaffleTicket.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
    raffle = json['raffle'] != null ? Raffle.fromJson(json['raffle']) : null;
    order = json['order'];
    status = json['status'];
    ticketNumber = json['ticket_number'];
    isWinner = json['is_winner'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (raffle != null) {
      data['raffle'] = raffle!.toJson();
    }
    data['order'] = order;
    data['status'] = status;
    data['ticket_number'] = ticketNumber;
    data['is_winner'] = isWinner;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class CombinedTicket {
  String? ticketId;
  String? raffleNumber;
  // Raffle Draw details
  String? raffleId;
  String? ticketName;
  String? ticketDescription;
  String? ticketTracking;
  String? startDate;
  String? endDate;
  double? rafflePrice;
  bool? ticketStatus;
  List<Pictures>? pictures;

  CombinedTicket({
    this.ticketId,
    this.raffleNumber,

    this.raffleId,
    this.ticketName,
    this.ticketDescription,
    this.ticketTracking,
    this.startDate,
    this.endDate,
    this.rafflePrice,
    this.ticketStatus,
    this.pictures,
  });

  CombinedTicket.fromJson(Map<String, dynamic> json) {
    ticketId = json['id'];
    raffleNumber = json['raffle_number'];

    raffleId = json['raffledraw']['id'];
    ticketStatus = json['raffledraw']['status'];
    ticketName = json['raffledraw']['ticket_name'];
    ticketDescription = json['raffledraw']['ticket_description'];
    ticketTracking = json['raffledraw']['ticket_tracking'];
    startDate = json['raffledraw']['start_date'];
    endDate = json['raffledraw']['end_date'];
    rafflePrice = json['raffledraw']['raffle_price'].toDouble();
    if (json['raffledraw']['pictures'] != null) {
      pictures = List<Pictures>.from(json['raffledraw']['pictures'].map((model) => Pictures.fromJson(model)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = ticketId;
    data['raffle_number'] = raffleNumber;

    data['raffledraw']['id'] = raffleId;
    data['raffledraw']['ticket_name'] = ticketName;
    data['raffledraw']['ticket_description'] = ticketDescription;
    data['raffledraw']['ticket_tracking'] = ticketTracking;
    data['raffledraw']['start_date'] = startDate;
    data['raffledraw']['end_date'] = endDate;
    data['raffledraw']['raffle_price'] = rafflePrice;
    if (pictures != null) {
      data['raffledraw']['pictures'] = pictures!.map((v) => v.toJson()).toList();
    }


    return data;
  }
}

class SingleTicket {
  String? id;
  String? ticketTracking;
  bool? status;
  String? created;
  String? updated;

  SingleTicket(
      {this.id,
        this.ticketTracking,
        this.status,
        this.created,
        this.updated,});

  SingleTicket.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketTracking = json['ticket_tracking'];
    status = json['status'];
    created = json['created'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['raffle_number'] = ticketTracking;
    data['status'] = status;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

class Participants {
  String? id;
  String? raffleNumber;
  bool? status;
  String? created;
  String? updated;

  Participants(
      {this.id, this.raffleNumber, this.status, this.created, this.updated});

  Participants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    raffleNumber = json['raffle_number'];
    status = json['status'];
    created = json['created'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['raffle_number'] = raffleNumber;
    data['status'] = status;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

class Winner {
  String? id;
  bool? isWinner;
  String? status;
  String? ticketNumber;
  DateTime? createdAt;
  DateTime? updatedAt;
  Profile? user;
  Raffle? raffle;
  String? order;

  Winner({
    this.id,
    this.isWinner,
    this.status,
    this.ticketNumber,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.raffle,
    this.order,
  });

  // Updated fromJson method to match the response structure
  Winner.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    isWinner = json['is_winner'] is bool ? json['is_winner'] : null;
    status = json['status'];
    ticketNumber = json['ticket_number'];
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
    raffle = json['raffle'] != null ? Raffle.fromJson(json['raffle']) : null;
    order = json['order'];
  }

  // Updated toJson method to serialize the Winner object properly
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['is_winner'] = isWinner;
    data['status'] = status;
    data['ticket_number'] = ticketNumber;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (raffle != null) {
      data['raffle'] = raffle!.toJson();
    }
    data['order'] = order;
    return data;
  }
}


