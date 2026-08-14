enum AdMediaType { image, video, gif }

class AdMedia {
  final String id;
  final String? title;
  final String? description;
  final String mediaUrl;
  final AdMediaType mediaType;
  final String? linkUrl;
  final bool active;
  final int order;

  AdMedia({
    required this.id,
    this.title,
    this.description,
    required this.mediaUrl,
    required this.mediaType,
    this.linkUrl,
    required this.active,
    required this.order,
  });

  factory AdMedia.fromJson(Map<String, dynamic> json) {
    return AdMedia(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: _mapMediaType(json['mediaType']),
      linkUrl: json['linkUrl'],
      active: json['active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  static AdMediaType _mapMediaType(String? type) {
    switch (type) {
      case 'video':
        return AdMediaType.video;
      case 'gif':
        return AdMediaType.gif;
      default:
        return AdMediaType.image;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType.name,
      'linkUrl': linkUrl,
      'active': active,
      'order': order,
    };
  }
}
