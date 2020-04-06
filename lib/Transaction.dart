class Transaction {
  int topupId;
  double amount;
  String time;
  String userId;
  String userName;
  String remark;
  String cleared;

  Transaction(int topupId, double amount, String time, String userId, String userName, remark, cleared) {
    this.topupId = topupId;
    this.amount = amount;
    this.time = time;
    this.userId = userId;
    this.userName = userName;
    this.remark = remark;
    this.cleared = cleared;
  }

  Transaction.fromJson(Map json)
      : topupId = json['id'],
        amount = json['amount'],
        time = json['time'],
        userId = json['user']['id'],
        userName = json['user']['name'],
        remark = json['remark'],
        cleared = json['cleared'];

  Map toJson() {
    return {'id': topupId, 'amount': amount, 'time': time, 'user': { 'id': userId, 'name': userName }, 'remark': remark, 'cleared': cleared };

  }
}