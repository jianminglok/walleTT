class Transaction {
  int topupId;
  double amount;
  String time;
  String userId;
  String userName;
  String remark;
  String reversed;
  String cleared;

  Transaction(int topupId, double amount, String time, String userId, String userName, remark, reversed, cleared) {
    this.topupId = topupId;
    this.amount = amount;
    this.time = time;
    this.userId = userId;
    this.userName = userName;
    this.remark = remark;
    this.reversed = reversed;
    this.cleared = cleared;
  }

  Transaction.fromJson(Map json)
      : topupId = json['id'],
        amount = json['amount'],
        time = json['time'],
        userId = json['user']['id'],
        userName = json['user']['name'],
        remark = json['remark'],
        reversed = json['reversed'],
        cleared = json['cleared'];

  Map toJson() {
    return {'id': topupId, 'amount': amount, 'time': time, 'user': { 'id': userId, 'name': userName }, 'remark': remark, 'reversed': reversed, 'cleared': cleared };

  }
}