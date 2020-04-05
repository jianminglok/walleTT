class Product {
  String productId;
  String name;
  double price;

  Product(String productId, String name, double price) {
    this.productId = productId;
    this.name = name;
    this.price = price;
  }

  Product.fromJson(Map json)
      : productId = json['id'],
        name = json['name'],
        price = json['price'];

  Map toJson() {
    return {'id': productId, 'name': name, 'price': price};
  }
}