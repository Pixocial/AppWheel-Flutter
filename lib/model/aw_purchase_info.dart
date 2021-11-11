class AWPurchaseInfo {
  ///product id
  late String productId;

  ///订单号
  late String orderId;

  ///支付类型（1 订阅 2 内购）:android
  int paymentType = 2;

  ///购买时间
  late int purchaseTime;

  ///令牌具有唯一性，用于针对给定商品和用户对的购买进行标识。
  late String? purchaseToken;

  ///订单的购买状态:The purchase state of the order. Possible values are: 0. Purchased 1. Canceled 2. Pending
  late int purchaseState;

  ///是否自动续费
  bool autoRenewing = false;

  ///混淆后的账号id
  String? obfuscatedAccountId;

  ///混淆后的账号id
  String? obfuscatedProfileId;

  ////订阅独有的////
  ///是否处于宽限期
  bool inGracePeriod = false;

  ///过期时间
  late int? expireTime;


  static AWPurchaseInfo fromAndroidJson(Map<String, dynamic> json) {
    final purchaseInfo = AWPurchaseInfo();
    purchaseInfo.productId = json["productId"];
    purchaseInfo.orderId = json["orderId"];
    purchaseInfo.purchaseToken = json["purchaseToken"];
    purchaseInfo.obfuscatedAccountId = json["obfuscatedAccountId"];
    purchaseInfo.obfuscatedProfileId = json["obfuscatedProfileId"];
    purchaseInfo.paymentType = json["paymentType"];
    purchaseInfo.purchaseTime = json["purchaseTime"];
    purchaseInfo.purchaseState = json["purchaseState"];
    purchaseInfo.autoRenewing = json["autoRenewing"];
    if (json["inGracePeriod"] != null) {
      purchaseInfo.inGracePeriod = json["inGracePeriod"];
    }
    purchaseInfo.expireTime = json["expireTime"];

    return purchaseInfo;
  }

  @override
  String toString() {
    return 'AWPurchaseInfo{productId: $productId,\n '
        'orderId: $orderId, \n'
        'paymentType: $paymentType,\n '
        'purchaseTime: $purchaseTime, \n'
        'purchaseToken: ${purchaseToken??""},\n'
        ' purchaseState: $purchaseState, \n'
        'autoRenewing: $autoRenewing, \n'
        'obfuscatedAccountId: ${obfuscatedAccountId??""},\n'
        ' obfuscatedProfileId: ${obfuscatedProfileId??""}, \n'
        'inGracePeriod: $inGracePeriod,\n '
        'expireTime: $expireTime}';
  }
}

