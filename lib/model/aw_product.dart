import 'package:aw_purchase/util/aw_common_util.dart';

///用来存放商品信息的，里面的字段既有iOS专用的也有安卓专用的
class AWProduct {
  static final String PRODUCT_TYPE_INAPP = "inapp";
  static final String PRODUCT_TYPE_SUBS = "subs";

  /// 商品ID
  late final String productId;

  /// 商品类型,安卓使用的:inapp、subs
  String? productType;

  /// 商品类型,ios使用的:
  /// 0:消耗型商品
  /// 1：非消耗型商品
  /// 2：续期订阅
  /// 3：非续期订阅
  int? productTypeInt;

  /// 商品的格式化价格，包括货币符号。此价格不含税。
  late final String price;

  /// 商品价格
  /// Android：1000000 个微单位等于 1 单位的货币
  late final int priceAmount;

  /// 商品的格式化原价格，包括货币符号。此价格不含税。
  late final String originalPrice;

  /// 商品原始价格
  /// Android：1000000 个微单位等于 1 单位的货币
  late final int originalPriceAmount;

  /// 货币代码
  late final String priceCurrency;

  /// 商品的标题
  String? title;

  /// 商品的描述
  String? description;

  /// 商品的购买数量，iOS用
  String? quantity;

  /// 是否支持家庭共享，iOS用
  bool isFamilyShareable = false;

  //////订阅专用的
  ///订阅周期：采用 ISO 8601 格式指定。例如，P7D 相当于七天
  String? subscriptionPeriod;

  ///推介促销优惠
  ProductDiscount? introductDiscount;

  ///普通优惠，安卓的免费也放到这里了
  List<ProductDiscount>? discounts;

  ///ios用
  ///订阅群组,ios 用
  String? subscriptionGroupId;

  @override
  String toString() {
    return '{productId: $productId, \n'
        'productType: ${printParam(productType)}, \n'
        'productTypeInt: $productTypeInt, \n'
        'price: $price, \n'
        'priceAmount: $priceAmount, \n'
        'originalPrice: $originalPrice,\n'
        ' originalPriceAmount: $originalPriceAmount, \n'
        'priceCurrency: $priceCurrency, \n'
        'title: ${printParam(title)}, \n'
        'description: ${printParam(description)}, \n'
        'quantity: ${printParam(quantity)}, \n'
        'isFamilyShareable: $isFamilyShareable, \n'
        'subscriptionPeriod: ${printParam(subscriptionPeriod)}, \n'
        'introductDiscount: $introductDiscount, \n'
        'discounts: $discounts, \n'
        'subscriptionGroupId: ${printParam(subscriptionGroupId)}}';
  }

  String toAndroidJson() {
    if (AWCommonUtil.strNotEmpty(productType) &&
        productType == PRODUCT_TYPE_INAPP) {
      return '{\"productId\":\"$productId\",'
          '\"type\":\"$productType\",'
          '\"title\":\"${AWCommonUtil.strNotEmpty(title) ? title : ""}\",'
          '\"price_currency_code\":\"${AWCommonUtil.strNotEmpty(priceCurrency) ? priceCurrency : ""}\",'
          '\"price_amount_micros\":\"$priceAmount\",'
          '\"price\":\"${AWCommonUtil.strNotEmpty(price) ? price : ""}\",'
          '\"original_price_micros\":\"$originalPriceAmount\",'
          '\"original_price\":\"${AWCommonUtil.strNotEmpty(originalPrice) ? originalPrice : ""}\",'
          '\"description\":\"${AWCommonUtil.strNotEmpty(description) ? description : ""}\"'
          '}';
    }
    if (AWCommonUtil.strNotEmpty(productType) &&
        productType == PRODUCT_TYPE_SUBS) {
      String? introductoryPricePeriod;
      int? introductoryAmountPrice;
      int? introductoryPriceCycles;
      if (introductDiscount != null &&
          AWCommonUtil.strNotEmpty(introductDiscount?.discountPeriod)) {
        introductoryPricePeriod = introductDiscount?.discountPeriod;
        introductoryAmountPrice = introductDiscount?.discountPrice;
        introductoryPriceCycles = introductDiscount?.discountCycle;
      }
      String? freeTrialPeriod;
      if (discounts != null && discounts![0] != null) {
        if (AWCommonUtil.strNotEmpty(discounts![0].discountPeriod)) {
          freeTrialPeriod = discounts![0].discountPeriod;
        }
      }
      return '{\"productId\":\"$productId\",'
          '\"type\":\"$productType\",'
          '\"title\":\"${AWCommonUtil.strNotEmpty(title) ? title : ""}\",'
          '\"price_currency_code\":\"${AWCommonUtil.strNotEmpty(priceCurrency) ? priceCurrency : ""}\",'
          '\"price_amount_micros\":\"$priceAmount\",'
          '\"price\":\"${AWCommonUtil.strNotEmpty(price) ? price : ""}\",'
          '\"original_price_micros\":\"$originalPriceAmount\",'
          '\"original_price\":\"${AWCommonUtil.strNotEmpty(originalPrice) ? originalPrice : ""}\",'
          '\"description\":\"${AWCommonUtil.strNotEmpty(description) ? description : ""}\",'
          '\"freeTrialPeriod\":\"${AWCommonUtil.strNotEmpty(freeTrialPeriod) ? freeTrialPeriod : ""}\",'
          '\"introductoryPricePeriod\":\"${AWCommonUtil.strNotEmpty(introductoryPricePeriod) ? introductoryPricePeriod : ""}\",'
          '\"introductoryAmountPrice\":\"$introductoryAmountPrice\",'
          '\"introductoryPriceCycles\":\"$introductoryPriceCycles\"'
          '}';
    }
    return '';
  }

  ///android用
  static AWProduct fromAndroidJson(Map<String, dynamic> json) {
    final product = AWProduct();
    product.productId = json["productId"];
    product.productType = json["type"];
    product.price = json["price"];
    product.priceAmount = json["price_amount_micros"];
    product.originalPrice = json["original_price"];
    product.originalPriceAmount = json["original_price_micros"];
    product.priceCurrency = json["price_currency_code"];
    product.title = json["title"];
    if (json["type"] == AWProduct.PRODUCT_TYPE_SUBS) {
      product.subscriptionPeriod = json["subscriptionPeriod"];
      if (json["introductoryAmountPrice"] != null &&
          json["price_currency_code"] != null &&
          json["price_currency_code"].toString().length > 0 &&
          json["introductoryPricePeriod"] != null &&
          json["introductoryPricePeriod"].toString().length > 0 &&
          json["introductoryPriceCycles"] != null)
        product.introductDiscount = ProductDiscount.fromAndroidParams(
            json["introductoryAmountPrice"],
            json["price_currency_code"],
            json["introductoryPricePeriod"],
            json["introductoryPriceCycles"]);
      product.discounts = json["freeTrialPeriod"] == null ||
              json["freeTrialPeriod"].toString().length <= 0
          ? null
          : [
              ProductDiscount.fromAndroidParams(
                  0, json["price_currency_code"], json["freeTrialPeriod"], 1)
            ];
    }
    return product;
  }
}

/// 商品的折扣, ios 用
class ProductDiscount {
  ///优惠的id
  late String? discountId;

  ///优惠的价格
  late int? discountPrice;

  ///优惠的价格货币代码
  late String? discountPriceCurrency;

  ///优惠的周期：采用 ISO 8601 格式指定。例如，P7D 相当于七天
  late String? discountPeriod;

  ///优惠的支付方式
  ///0：PayAsYouGo
  ///1：PayUpFront
  ///1：FreeTrial
  late int? discountPaymentModel;

  ///优惠循环几次
  late int? discountCycle;

  ProductDiscount.fromAndroidParams(
      int? price, String? priceCurrency, String? period, int? cycles)
      : discountId = "",
        discountPrice = price,
        discountPriceCurrency = priceCurrency,
        discountPeriod = period,
        discountCycle = cycles,
        //如果周期大于1那就是随用随付，等于1就是一次性付款了
        discountPaymentModel = (cycles != null && cycles > 1) ? 0 : 1;

  @override
  String toString() {
    return '{discountId: ${printParam(discountId)}, '
        'discountPrice: $discountPrice, discountPriceCurrency: ${printParam(discountPriceCurrency)}, '
        'discountPeriod: ${printParam(discountPeriod)}, discountPaymentModel: $discountPaymentModel, '
        'discountCycle: $discountCycle}';
  }
}

String printParam(String? str) {
  if (str != null && str.length > 0) {
    return str;
  }
  return "";
}
