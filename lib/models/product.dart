enum ProductType {
  livingroom,
  bedroom,
  diningroom,
  homeaccent,
  lighting,
}

class Product {
  const Product({
    required this.createAt,
    required this.stockQuantity,
    required this.description,
    required this.name,
    required this.rate,
    required this.color,
    required this.price,
    required this.linkImg,
    required this.type,
    required this.weight,
    required this.colorCode,
    required this.linkImageMatch,
    required this.sale,
    required this.id,
  });
  final String id;
  final DateTime createAt;
  final int stockQuantity;
  final int sale;
  final String description;
  final String name;
  final double rate;
  final List color;
  final List<int> colorCode;
  final List linkImageMatch;
  final List linkImg;
  final int price;
  final double weight; // kg
  final String type;
  Map<String, dynamic> getProductData() {
    return {
      "create_at": createAt,
      "stock_quantity": stockQuantity,
      "description": description,
      "name": name,
      "rate": rate,
      "color": color,
      "link_img": linkImg,
      "price": price,
      "weight": weight,
      "type": type,
      "link_image_match": linkImageMatch,
      "color_code": colorCode,
      "sale": sale,
    };
  }
}
