class ServiceRequest {
  final String id;
  final String serviceName;
  final String status;
  final String date;
  final String time;
  final String address;
  final String createdAt;
  final String updatedAt;
  final String? description;
  final AssignedPersonnel? assignedPersonnel;
  final List<String>? attachments;
  final String? reason;
  final String? feedback;
  final int? rating;

  ServiceRequest({
    required this.id,
    required this.serviceName,
    required this.status,
    required this.date,
    required this.time,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.assignedPersonnel,
    this.attachments,
    this.reason,
    this.feedback,
    this.rating,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {

    String formattedAddress = '';
    if (json['address'] != null) {
      final addr = json['address'];
      formattedAddress = '${addr['address']}, ${addr['city']}, ${addr['state']}';
    }

    AssignedPersonnel? personnel;
    if (json['personnel'] != null) {
      final p = json['personnel'];
      personnel = AssignedPersonnel(
        name: '${p['firstName']} ${p['lastName']}',
        phone: p['phoneNumber'] ?? '',
        email: p['email'] ?? '',
      );
    }

    return ServiceRequest(
      id: json['id'],
      serviceName: json['service']?['name'] ?? 'Unknown Service',
      status: json['status'] ?? 'pending',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      address: formattedAddress,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      description: json['description'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      assignedPersonnel: personnel,
      reason: json['reason'],
      feedback: json['feedback'],
      rating: json['rating'],
    );
  }
}

class AssignedPersonnel {
  final String name;
  final String phone;
  final String email;

  AssignedPersonnel({
    required this.name,
    required this.phone,
    required this.email,
  });
}