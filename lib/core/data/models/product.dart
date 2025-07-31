
import 'package:easyph/core/data/models/tags.dart';

class Product {
  String? id;
  String? productName;
  String? productDescription;
  String? price;
  String? salePrice;
  double? rating;
  int? availability;
  int? stock;
  bool? ad;
  bool? featured;
  bool? lowStockAlert;
  int? categoryId;
  int? verifiedSales;
  String? brandName;
  int? modelNumber;
  String? createdAt;
  String? updatedAt;
  bool? installment;
  int? installmentFrequency;
  String? status;
  List<String>? reviews;
  List<String>? images;
  List<Tag>? tags;

  Product({
    this.id,
    this.productName,
    this.productDescription,
    this.price,
    this.salePrice,
    this.rating,
    this.availability,
    this.stock,
    this.ad,
    this.featured,
    this.lowStockAlert,
    this.categoryId,
    this.verifiedSales,
    this.brandName,
    this.modelNumber,
    this.createdAt,
    this.updatedAt,
    this.reviews,
    this.images,
    this.installment,
    this.status,
    this.installmentFrequency,
    this.tags,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['name'];
    productDescription = json['description'];
    price = json['price']?.toString() ?? '0';
    salePrice = json['salePrice']?.toString() ?? '0';
    rating = double.tryParse(json['rating']?.toString() ?? '0.0');
    availability = json['availability'];
    stock = json['stock'];
    ad = json['ad'];
    featured = json['featured'];
    lowStockAlert = json['lowStockAlert'];
    categoryId = json['categoryId'] is int ? json['categoryId'] : int.tryParse(json['categoryId']?.toString() ?? '0');
    verifiedSales = json['verifiedSale']; // Corrected key
    brandName = json['brandName'];
    modelNumber = json['modelNumber'] is int ? json['modelNumber'] : int.tryParse(json['modelNumber']?.toString() ?? '0');
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    reviews = json['reviews'] != null ? List<String>.from(json['reviews']) : null;
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    installment = json['installment'];
    installmentFrequency = json['installmentFrequency'];
    status = json['status'];

    tags = json['tags'] != null
        ? (json['tags'] as List).map((tagJson) => Tag.fromJson(tagJson)).toList()
        : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = productName;
    data['description'] = productDescription;
    data['price'] = price;
    data['salePrice'] = salePrice;
    data['rating'] = rating;
    data['availability'] = availability;
    data['stock'] = stock;
    data['ad'] = ad;
    data['featured'] = featured;
    data['lowStockAlert'] = lowStockAlert;
    data['categoryId'] = categoryId;
    data['verifiedSale'] = verifiedSales;
    data['brandName'] = brandName;
    data['modelNumber'] = modelNumber;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['installment'] = installment;
    data['installmentFrequency'] = installmentFrequency;
    data['status'] = status;
    if (reviews != null) {
      data['reviews'] = reviews;
    }
    if (images != null) {
      data['images'] = images;
    }

    if (tags != null) {
      data['tags'] = tags!.map((tag) => tag.toJson()).toList();
    }

    return data;
  }
}



class Pictures {
  String? id;
  String? token;
  String? location;
  int? type;
  bool? isPopup;
  bool? front;
  String? create;
  String? updated;

  Pictures(
      {this.id,
      this.token,
      this.location,
      this.type,
      this.isPopup,
      this.front,
      this.create,
      this.updated});

  Pictures.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
    location = json['location'];
    type = json['type'];
    isPopup = json['isPopup'];
    front = json['front'];
    create = json['create'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['token'] = token;
    data['location'] = location;
    data['type'] = type;
    data['isPopup'] = isPopup;
    data['front'] = front;
    data['create'] = create;
    data['updated'] = updated;
    return data;
  }
}

class Raffle {
  String? id;
  String? name;
  String? description;
  int? availableTickets;
  List<Media>? media;
  String? startDate;
  String? endDate;
  int? ticketPrice;
  String? status;
  String? winningTicket;
  String? createdAt;
  String? updatedAt;
  String? formattedTicketPrice;
  List<Participant>? participants;

  Raffle({
    this.id,
    this.name,
    this.description,
    this.availableTickets,
    this.media,
    this.startDate,
    this.endDate,
    this.ticketPrice,
    this.status,
    this.winningTicket,
    this.createdAt,
    this.updatedAt,
    this.formattedTicketPrice,
    this.participants,
  });

  Raffle.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['_id'];
    name = json['name'];
    description = json['description'];
    availableTickets = json['available_tickets'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    startDate = json['start_date'];
    endDate = json['end_date'];
    ticketPrice = json['ticket_price'];
    status = json['status'];
    winningTicket = json['winning_ticket'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    formattedTicketPrice = json['formatted_ticket_price'];
    if (json['participants'] != null) {
      participants = <Participant>[];
      json['participants'].forEach((v) {
        participants!.add(Participant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['available_tickets'] = availableTickets;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['ticket_price'] = ticketPrice;
    data['status'] = status;
    data['winning_ticket'] = winningTicket;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['formatted_ticket_price'] = formattedTicketPrice;
    if (participants != null) {
      data['participants'] = participants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Ads {
  String? id;
  String? uploadKey;
  String? location;
  String? url;
  String? mimetype;
  String? mediaType;
  DateTime? createdAt;
  DateTime? updatedAt;

  Ads({
    this.id,
    this.uploadKey,
    this.location,
    this.url,
    this.mimetype,
    this.mediaType,
    this.createdAt,
    this.updatedAt,
  });

  Ads.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    uploadKey = json['upload_key'];
    location = json['location'];
    url = json['url'];
    mimetype = json['mimetype'];
    mediaType = json['media_type'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['upload_key'] = uploadKey;
    data['location'] = location;
    data['url'] = url;
    data['mimetype'] = mimetype;
    data['media_type'] = mediaType;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }
}


class Media {
  String? id;
  String? uploadKey;
  String? location;
  String? url;
  String? mimetype;
  String? createdAt;
  String? updatedAt;

  Media({
    this.id,
    this.uploadKey,
    this.location,
    this.url,
    this.mimetype,
    this.createdAt,
    this.updatedAt,
  });

  Media.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    uploadKey = json['upload_key'];
    location = json['location'];
    url = json['url'];
    mimetype = json['mimetype'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['upload_key'] = uploadKey;
    data['location'] = location;
    data['url'] = url;
    data['mimetype'] = mimetype;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Participant {
  String? firstname;
  String? lastname;
  ProfilePic? profilePic;

  Participant({this.firstname, this.lastname, this.profilePic});

  Participant.fromJson(Map<String, dynamic> json) {
    firstname = json['firstname'];
    lastname = json['lastname'];
    profilePic = json['profile_pic'] != null
        ? ProfilePic.fromJson(json['profile_pic'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    if (profilePic != null) {
      data['profile_pic'] = profilePic!.toJson();
    }
    return data;
  }
}

class ProfilePic {
  String? id;
  String? url;

  ProfilePic({this.id, this.url});

  ProfilePic.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['url'] = url;
    return data;
  }
}

class Review {
  final String content;
  final String reviewerName;
  final DateTime date;
  final double rating;

  Review({
    required this.content,
    required this.reviewerName,
    required this.date,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      content: json['reviewText'],
      reviewerName: "${json['User']['firstName']} ${json['User']['lastName']}",
      date: DateTime.parse(json['createdAt']),
      rating: (json['rating'] as num).toDouble(),
    );
  }
}





class DrawEvent {
  final String id;
  final Raffle raffle;
  final String title;
  final String link;
  final List<Media> media;
  final DateTime createdAt;
  final DateTime updatedAt;

  DrawEvent({
    required this.id,
    required this.raffle,
    required this.title,
    required this.link,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DrawEvent.fromJson(Map<String, dynamic> json) {
    return DrawEvent(
      id: json['_id'],
      raffle: Raffle.fromJson(json['raffle']),
      title: json['title'],
      link: json['link'],
      media: (json['media'] as List)
          .map((mediaItem) => Media.fromJson(mediaItem))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Add the toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'raffle': raffle.toJson(), // Assuming Raffle also has a toJson method
      'title': title,
      'link': link,
      'media': media.map((m) => m.toJson()).toList(), // Assuming Media also has a toJson method
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}


