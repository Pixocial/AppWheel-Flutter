// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:appwheel_flutter/model/aw_coupon_model.dart';
import 'package:appwheel_flutter/model/up_or_down_grade_model.dart';
import 'package:flutter/services.dart';

import 'aw_observer.dart';
import 'model/aw_base_respon_model.dart';
import 'model/aw_parse_native_model.dart';
import 'model/aw_product.dart';
import 'model/aw_order.dart';

class AWPurchase {
  static AWObserver? observer;
  static final MethodChannel _channel = MethodChannel('appwheel_flutter')
    ..setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onPurchased":
          handleOnPurchased(call);
      }
    });

  static handleOnPurchased(MethodCall call) {
    final result = json.decode(call.arguments);

    int platform = result["platform"];
    List<AWOrder> purchaseList = [];

    /// ios
    if (platform == AwPlatformType.ios.index) {
      //订阅
      final List subs = result["subs"] ?? [];
      for (var purchaseJson in subs) {
        purchaseList.add(AWOrder.fromIosJson(purchaseJson));
      }
      //消耗品、非消耗品、非续期订阅
      final List inapps = result["inapps"] ?? [];
      for (var purchaseJson in inapps) {
        purchaseList.add(AWOrder.fromIosJson(purchaseJson));
      }
    }

    /// android
    if (platform == AwPlatformType.android.index) {
      final List purchaseStr = result["orderList"];
      for (var purchaseJson in purchaseStr) {
        purchaseList.add(AWOrder.fromAndroidJson(purchaseJson));
      }
    }

    observer?.onPurchased(purchaseList);
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<AWResponseModel<bool>> init(
      String appId, String? appUserId) async {
    var result = await _channel
        .invokeMethod('init', {"appId": appId, "appUserId": appUserId});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    return AWResponseModel.sendSuccess(true);
  }

  /// 恢复购买
  /// platform:平台，1：Android，2：iOS
  static Future<AWResponseModel<List<AWOrder>>?> restore(
      AwPlatformType type) async {
    if (type == AwPlatformType.android) {
      return androidRestore();
    }
    if (type == AwPlatformType.ios) {
      return iosRestore();
    }
  }

  static Future<AWResponseModel<List<AWOrder>>> androidRestore() async {
    var result = await _channel.invokeMethod('restore');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWOrder> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    final List purchaseStr = model.data;
    for (var purchaseJson in purchaseStr) {
      purchaseList.add(AWOrder.fromAndroidJson(purchaseJson));
    }
    return AWResponseModel.sendSuccess(purchaseList);
  }

  static Future<AWResponseModel<List<AWOrder>>> iosRestore() async {
    var result = await _channel.invokeMethod('restore');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWOrder> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    return parseIosOrder(model.data, purchaseList);
  }

  /// 请求商品信息
  /// platform:平台，1：Android，2：iOS
  /// productType: 安卓使用的，inapp、subs
  static Future<AWResponseModel<List<AWProduct>>?> requestProducts(
      AwPlatformType type, String productType, List<String> productIds) async {
    if (type == AwPlatformType.android) {
      return requestAndroidProducts(productType, productIds);
    }
    if (type == AwPlatformType.ios) {
      return requestIosProducts(productIds);
    }
  }

  /// 请求安卓的商品信息
  static Future<AWResponseModel<List<AWProduct>>> requestAndroidProducts(
      String productType, List<String> products) async {
    var result = await _channel.invokeMethod(
        'requestProducts', {"productType": productType, "products": products});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    //开始对安卓的数据进行解析
    final List<AWProduct> productList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(productList);
    }
    final List productsStr = model.data;
    for (var productJson in productsStr) {
      productList.add(AWProduct.fromAndroidJson(productJson));
    }
    return AWResponseModel.sendSuccess(productList);
  }

  /// 请求ios的商品信息
  static Future<AWResponseModel<List<AWProduct>>> requestIosProducts(
      List<String> products) async {
    var result =
        await _channel.invokeMethod('requestProducts', {"products": products});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    //开始对ios的数据进行解析
    final List<AWProduct> productList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(productList);
    }
    if (model.data["validProducts"] == null) {
      return AWResponseModel.sendFailed("Invalid sku");
    }
    final List productsStr = model.data["validProducts"];
    for (var productJson in productsStr) {
      productList.add(AWProduct.fromIosJson(productJson));
    }
    return AWResponseModel.sendSuccess(productList);
  }

  /// 购买商品
  /// platform 平台，1：Android，2：iOS
  static Future<AWResponseModel<AWOrder>?> purchase(
      AwPlatformType type, AWProduct product,{String productType = "",int quantity = 1, AWProductDiscount? discount}) async {
    if (type == AwPlatformType.android) {
      return purchaseAndroid(product);
    }
    if (type == AwPlatformType.ios) {
      if (productType == "") {
        return AWResponseModel.sendFailed("need set productType");
      }
      return purchaseIos(product,productType,quantity,discount);
    }
  }

  ///购买安卓的商品
  static Future<AWResponseModel<AWOrder>> purchaseAndroid(
      AWProduct product) async {
    // 需要把product解析成安卓需要的数据格式
    final androidString = product.toAndroidJson();
    var result =
        await _channel.invokeMethod('purchase', {"product": androidString});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final purchaseInfo = AWOrder.fromAndroidJson(model.data);
    return AWResponseModel.sendSuccess(purchaseInfo);
  }

  ///购买iOS的商品
  static Future<AWResponseModel<AWOrder>> purchaseIos(AWProduct product,String productType,int quantity,AWProductDiscount? discount) async {
    product.productType = productType;
    product.quantity = quantity;
    // 需要把product解析成安卓需要的数据格式
    final iosString = product.toIosJson();
    var result =
        await _channel.invokeMethod('purchase', {"product": iosString,"discountId":discount?.discountId??""});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final purchaseInfo = AWOrder.fromIosJson(model.data);
    return AWResponseModel.sendSuccess(purchaseInfo);
  }

  ///消耗安卓的商品
  static Future<AWResponseModel<String>> consume(AWOrder order) async {
    // 需要把product解析成安卓需要的数据格式
    final androidString = order.toAndroidJson();
    var result =
        await _channel.invokeMethod('consume', {"order": androidString});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    return AWResponseModel.sendSuccess(model.data);
  }

  ///升、降级安卓的购买
  static Future<AWResponseModel<AWOrder>> upOrDownGradePurchase(
      AWProduct product, UpOrDownGradeModel upOrDownGradeModel) async {
    // 需要把product解析成安卓需要的数据格式
    final androidString = product.toAndroidJson();
    final upOrDownGradeString = upOrDownGradeModel.toString();
    var result =
        await _channel.invokeMethod('upOrDownGradePurchase', {"product": androidString,"upOrDownGradeModel": upOrDownGradeString});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final purchaseInfo = AWOrder.fromAndroidJson(model.data);
    return AWResponseModel.sendSuccess(purchaseInfo);
  }

  ///获取有效订单列表
  static Future<AWResponseModel<List<AWOrder>>?> getOrderList(
      AwPlatformType type) async {
    if (type == AwPlatformType.android) {
      return getAndroidOrderList();
    }
    if (type == AwPlatformType.ios) {
      return getIosOrderList();
    }
  }

  static Future<AWResponseModel<List<AWOrder>>> getAndroidOrderList() async {
    var result = await _channel.invokeMethod('getOrderList');
    return parseAndroidOrder(result);
    // final model = getResponseModel(result);
    // if (!model.result) {
    //   return AWResponseModel.sendFailed(model.msg);
    // }
    // final List<AWOrder> purchaseList = [];
    // if (model.data == null) {
    //   return AWResponseModel.sendSuccess(purchaseList);
    // }
    // final List purchaseStr = model.data;
    // for (var purchaseJson in purchaseStr) {
    //   purchaseList.add(AWOrder.fromAndroidJson(purchaseJson));
    // }
    // return AWResponseModel.sendSuccess(purchaseList);
  }

  static Future<AWResponseModel<List<AWOrder>>> getIosOrderList() async {
    var result = await _channel.invokeMethod('getOrderList');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWOrder> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    return parseIosOrder(model.data, purchaseList);
  }

  ///获取历史订单列表
  static Future<AWResponseModel<List<AWOrder>>?> getHistoryOrderList(
      AwPlatformType type) async {
    if (type == AwPlatformType.android) {
      return getAndroidHistoryOrderList();
    }
    //ios
    if (type == AwPlatformType.ios) {
      return getIosHistoryOrderList();
    }
  }

  static Future<AWResponseModel<List<AWOrder>>>
      getAndroidHistoryOrderList() async {
    var result = await _channel.invokeMethod('getHistoryOrderList');
    return parseAndroidOrder(result);
  }

  static Future<AWResponseModel<List<AWOrder>>> getIosHistoryOrderList() async {
    var result = await _channel.invokeMethod('getHistoryOrderList');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWOrder> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    return parseIosOrder(model.data, purchaseList);
  }

  /// 退款--仅供安卓
  static Future<AWResponseModel<bool>> revoke(String productId) async {
    var result =
        await _channel.invokeMethod('revoke', {"productId": productId});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    return AWResponseModel.sendSuccess(model.result);
  }

  /// 退款--仅供安卓
  static Future<AWResponseModel<bool>> refund(String productId) async {
    var result =
        await _channel.invokeMethod('refund', {"productId": productId});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    return AWResponseModel.sendSuccess(model.result);
  }

  ///请求优惠券
  static Future<AWResponseModel<AWCouponModel>> queryCoupon() async {
    var result = await _channel.invokeMethod('queryCoupon');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final coupon = AWCouponModel.fromJson(model.data);
    return AWResponseModel.sendSuccess(coupon);
  }

  ///更新优惠券
  static Future<AWResponseModel<bool>> updateCoupon(int taskId) async {
    var result =
        await _channel.invokeMethod('updateCoupon', {"taskId": taskId});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    return AWResponseModel.sendSuccess(model.result);
  }

  ///解析iOS返回的订单数据：供订单列表和恢复购买使用的统一方法
  static Future<AWResponseModel<List<AWOrder>>> parseIosOrder(
      dynamic purchaseData, List<AWOrder> purchaseList) async {
    //订阅
    final List subs = purchaseData["subs"] ?? [];
    for (var purchaseJson in subs) {
      purchaseList.add(AWOrder.fromIosJson(purchaseJson));
    }

    //消耗品、非消耗品、非续期订阅
    final List inapps = purchaseData["inapps"] ?? [];
    for (var purchaseJson in inapps) {
      purchaseList.add(AWOrder.fromIosJson(purchaseJson));
    }
    return AWResponseModel.sendSuccess(purchaseList);
  }

  static Future<AWResponseModel<List<AWOrder>>> parseAndroidOrder(
      dynamic result) async {
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWOrder> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    final List purchaseStr = model.data;
    for (var purchaseJson in purchaseStr) {
      purchaseList.add(AWOrder.fromAndroidJson(purchaseJson));
    }
    return AWResponseModel.sendSuccess(purchaseList);
  }

  static bool isSuccess(String result) {
    final model = AWParseNativeModel.fromJson(
        json.decode(result) as Map<String, dynamic>);
    return model.result == true;
  }

  static AWParseNativeModel getResponseModel(
    String result,
  ) {
    return AWParseNativeModel.fromJson(
        json.decode(result) as Map<String, dynamic>);
  }

  static void setObserver(AWObserver observer) {
    AWPurchase.observer = observer;
  }

  static void removeObserver() {
    AWPurchase.observer = null;
  }
}
