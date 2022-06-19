class CoinRecord {
  late int coinCount;
  late int date;
  late String desc;
  late int id;
  late int type;
  late int userId;
  late String userName;

  static CoinRecord? fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    CoinRecord coinRecordBean = CoinRecord();
    coinRecordBean.coinCount = map['coinCount'];
    coinRecordBean.date = map['date'];
    coinRecordBean.desc = map['desc'];
    coinRecordBean.id = map['id'];
    coinRecordBean.type = map['type'];
    coinRecordBean.userId = map['userId'];
    coinRecordBean.userName = map['userName'];
    return coinRecordBean;
  }

  Map toJson() => {
        "coinCount": coinCount,
        "date": date,
        "desc": desc,
        "id": id,
        "type": type,
        "userId": userId,
        "userName": userName,
      };
}
