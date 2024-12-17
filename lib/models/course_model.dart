class Course {
  late dynamic id;
  final String photo;
  final List<dynamic> videos;
  final String title;
  final String description;
  final double price;
  final bool isFavorite;
  final bool isInCart;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.photo,
    required this.videos,
    required this.price,
    required this.isFavorite,
    required this.isInCart,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photo': photo,
      'videos': videos,
      'title': title,
      'description': description,
      'price': price,
      'isFavorite': isFavorite ? true : false,
      'isInCart': isInCart ? true : false,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      photo: map['photo'] ?? '',
      videos: map['videos'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      isFavorite: map['isFavorite'] == true,
      isInCart: map['isInCart'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo': photo,
      'videos': videos,
      'price': price,
      'isFavorite': isFavorite ? true : false,
      'isInCart': isInCart ? true : false,
    };
  }

  // إنشاء كائن كورس من JSON - للتعامل مع البيانات المستخرجة من Firestore
  static Course fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      photo: json['photo'],
      videos: json['videos'],
      price: json['price'],
      isFavorite: json['isFavorite'] == true,
      isInCart: json['isInCart'] == true,
    );
  }

  factory Course.fromFirestore(String id, Map<String, dynamic> data) {
    return Course(
      id: id,
      photo: data['photo'] ?? '',
      videos: data['videos'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      isFavorite: data['isFavorite'] ?? '',
      isInCart: data['isInCart'] ?? '',
    );
  }
}
