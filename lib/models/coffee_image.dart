class CoffeeImage {
  final String url;

  CoffeeImage({required this.url});

  factory CoffeeImage.fromJson(Map<String, dynamic> json) {
    return CoffeeImage(url: json['file']);
  }

  Map<String, dynamic> toMap() {
    return {'url': url};
  }
}
