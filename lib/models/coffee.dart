class Coffee {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String type;
  final double rating;

  Coffee({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type,
    this.rating = 4.5,
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id: json['id'].toString(),
      name: json['name'] ?? 'No Name',
      description: json['description'] ?? 'No Description',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      type: json['type'] ?? 'hot',
      rating: double.tryParse(json['rating'].toString()) ?? 4.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'type': type,
      'rating': rating,
    };
  }
}