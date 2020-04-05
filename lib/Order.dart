class Order {
  int orderId;
  String status;
  double amount;
  String time;
  String userId;
  String userName;
  var products;
  var quantities;

  Order(int orderId, String status, double amount, String time, String userId, String userName, products, quantities) {
    this.orderId = orderId;
    this.status = status;
    this.amount = amount;
    this.time = time;
    this.userId = userId;
    this.userName = userName;
    this.products = products;
    this.quantities = quantities;
  }

  Order.fromJson(Map json)
      : orderId = json['id'],
        status = json['status'],
        amount = json['amount'],
        time = json['time'],
        userId = json['user']['id'],
        userName = json['user']['name'],
        products = json['products'],
        quantities = json['amounts'];

  Map toJson() {
    return {'id': orderId, 'status': status, 'amount': amount, 'time': time, 'user': { 'id': userId, 'name': userName }, 'products': products, 'amounts': quantities };

  }
}