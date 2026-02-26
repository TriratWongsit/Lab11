class CategoryModel {
  final int? id;
  final String name;
  final String colorHex; // เก็บสีรูป #RRGGBB
  final String iconKey;  // เก็บชื่อไอคอน

  CategoryModel({
    this.id,
    required this.name,
    required this.colorHex,
    required this.iconKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_key': iconKey,
    };
  }

  static CategoryModel fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      colorHex: map['color_hex'],
      iconKey: map['icon_key'],
    );
  }
}