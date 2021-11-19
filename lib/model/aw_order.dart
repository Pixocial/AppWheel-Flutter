class AWOrder {
  ///product id
  late String productId;

  ///订单号
  late String orderId;

  ///支付类型（1 订阅 2 内购）:android
  int paymentType = 2;

  ///购买时间
  String? purchaseTime;

  ///令牌具有唯一性，用于针对给定商品和用户对的购买进行标识。
  String? purchaseToken;

  ///订单的购买状态:The purchase state of the order. Possible values are: 0. Purchased 1. Canceled 2. Pending
  int? purchaseState;

  ///是否自动续费
  bool autoRenewing = false;

  ///混淆后的账号id
  String? obfuscatedAccountId;

  ///混淆后的账号id
  String? obfuscatedProfileId;

  ////订阅独有的////
  ///是否处于宽限期
  bool inGracePeriod = false;
  bool isInIntroPeriod = false;

  ///商品类型，iOS使用
  ///0：消耗型，1：非消耗型，2：订阅，3：非续期订阅
  String? productType;

  ///是否是家庭共享拥有者，iOS使用
  String? inAppOwnershipType;

  ///过期时间
  int? expireTime;

  static AWOrder fromAndroidJson(Map<String, dynamic> json) {
    final order = AWOrder();
    order.productId = json["productId"];
    order.orderId = json["orderId"];
    order.purchaseToken = json["purchaseToken"];
    order.obfuscatedAccountId = json["obfuscatedAccountId"];
    order.obfuscatedProfileId = json["obfuscatedProfileId"];
    order.paymentType = json["paymentType"];
    order.purchaseTime = json["purchaseTime"];
    order.purchaseState = json["purchaseState"];
    order.autoRenewing = json["autoRenewing"];
    if (json["inGracePeriod"] != null) {
      order.inGracePeriod = json["inGracePeriod"];
    }
    order.expireTime = json["expireTime"] ?? 0;

    return order;
  }

  static AWOrder fromIosJson(Map<String, dynamic> json) {
    final order = AWOrder();
    order.productId = json["productIdentifier"];
    order.orderId = json["originalTransactionId"];
    order.productType =
        json["productType"] != null ? json["productType"].toString() : "";
    order.isInIntroPeriod = json["isInIntroPeriod"] ?? false;
    if (json["subscriptionExpiredTime"] != null) {
      final date = DateTime.parse(json["subscriptionExpiredTime"]);
      order.expireTime = date.microsecondsSinceEpoch;
    }

    return order;
  }

  @override
  String toString() {
    return 'AWOrder{productId: $productId,\n '
        'orderId: $orderId, \n'
        'paymentType: $paymentType,\n '
        'purchaseTime: ${purchaseTime ?? ""}, \n'
        'purchaseToken: ${purchaseToken ?? ""},\n'
        ' purchaseState: ${purchaseState ?? 2}, \n'
        'autoRenewing: $autoRenewing, \n'
        'obfuscatedAccountId: ${obfuscatedAccountId ?? ""},\n'
        ' obfuscatedProfileId: ${obfuscatedProfileId ?? ""}, \n'
        'inGracePeriod: $inGracePeriod,\n '
        'expireTime: ${expireTime ?? 0}}';
  }
}

class IosProductType {
  static const String  consumables = "0";
  static const String  nonConsumables = "1";
  static const String  renewable = "2";
  static const String  nonRenewable = "3";
}

class AndroidProductType {
  static const int  subs = 1;
  static const int  inapps = 2;
}
