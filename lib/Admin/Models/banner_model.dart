class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String link;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.isActive,
  });

  BannerModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? link,
    bool? isActive,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'isActive': isActive,
    };
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      link: json['link'],
      isActive: json['isActive'],
    );
  }
}
