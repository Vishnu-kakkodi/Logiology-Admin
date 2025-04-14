class Product {
  final int id;
  final String title;
  final double price;
  final double rating;
  final String thumbnail;
  final String category;
  final List<String> tags;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.category,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      thumbnail: json['thumbnail'] ?? '',
      category: json['category'] ?? 'general',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
