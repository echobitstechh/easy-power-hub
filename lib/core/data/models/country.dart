

class Country {
  String? id;
  String? id2; // Changed to match '_id'
  String? name;
  String? currency;
  String? capital;
  String? code;
  String? isoCode; // Changed field name
  bool? isSupported;
  int? phoneCode; // Changed field name
  String? createdAt; // Changed field name
  String? updatedAt; // Changed field name

  Country({
    this.id,
    this.id2,
    this.name,
    this.currency,
    this.capital,
    this.code,
    this.isoCode,
    this.isSupported,
    this.phoneCode,
    this.createdAt,
    this.updatedAt,
  });

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    id2 = json['_id']; // Changed to match '_id'
    name = json['name'];
    currency = json['currency'];
    phoneCode = json['phone_code']; // Changed field name
    capital = json['capital'];
    code = json['code'];
    isoCode = json['iso_code']; // Changed field name
    isSupported = json['is_supported'];
    createdAt = json['createdAt']; // Changed field name
    updatedAt = json['updatedAt']; // Changed field name
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['_id'] = id2; // Changed to match '_id'
    data['name'] = name;
    data['currency'] = currency;
    data['phone_code'] = phoneCode; // Changed field name
    data['capital'] = capital;
    data['code'] = code;
    data['iso_code'] = isoCode; // Changed field name
    data['is_supported'] = isSupported;
    data['createdAt'] = createdAt; // Changed field name
    data['updatedAt'] = updatedAt; // Changed field name
    return data;
  }
}
