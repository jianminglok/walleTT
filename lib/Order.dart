class Order {
  int orderId;
  String status;
  double amount;
  String time;
  int userId;
  String userName;

  Order(int orderId, String status, double amount, String time, int userId, String userName) {
    this.orderId = orderId;
    this.status = status;
    this.amount = amount;
    this.time = time;
    this.userId = userId;
    this.userName = userName;
  }

  Order.fromJson(Map json)
      : orderId = json['id'],
        status = json['status'],
        amount = json['amount'],
        time = json['time'],
        userId = json['user']['id'],
        userName = json['user']['name'];

  Map toJson() {
    return {'id': orderId, 'status': status, 'amount': amount, 'time': time, 'user': { 'id': userId, 'name': userName } };

  }
}