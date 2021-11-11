// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:aw_purchase/model/aw_base_respon_model.dart';
import 'package:aw_purchase/model/aw_parse_native_model.dart';
import 'package:flutter/services.dart';
import 'package:aw_purchase/model/aw_product.dart';

import 'model/aw_purchase_info.dart';

class AwPurchase {
  static const MethodChannel _channel = const MethodChannel('aw_purchase');

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
  static Future<AWResponseModel<List<AWPurchaseInfo>>> restore(
      int platform) async {
    return androidRestore();
  }

  static Future<AWResponseModel<List<AWPurchaseInfo>>> androidRestore() async {
    var result = await _channel.invokeMethod('restore');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }

    final List purchaseStr = model.data;
    final List<AWPurchaseInfo> purchaseList = [];
    purchaseStr.forEach((purchaseJson) {
      purchaseList.add(AWPurchaseInfo.fromAndroidJson(purchaseJson));
    });
    return AWResponseModel.sendSuccess(purchaseList);
  }

  /// 请求商品信息
  /// platform:平台，1：Android，2：iOS
  /// productType: 安卓使用的，inapp、subs
  static Future<AWResponseModel<List<AWProduct>>> requestProducts(
      int platform, String productType, List<String> products) async {
    if (platform == 1) {
      return requestAndroidProducts(productType, products);
    }
    return AWResponseModel.sendFailed("errorMsg");
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
    final List productsStr = model.data;
    final List<AWProduct> productList = [];
    productsStr.forEach((productJson) {
      productList.add(AWProduct.fromAndroidJson(productJson));
    });
    return AWResponseModel.sendSuccess(productList);
  }

  //
  // static Future<dynamic> requestIosProducts(){
  //
  // }

  /// 购买商品
  /// platform 平台，1：Android，2：iOS
  static Future<AWResponseModel<AWPurchaseInfo>> purchase(
      int platform, AWProduct product) async {
    if (platform == 1) {
      return purchaseAndroid(product);
    }
    //ios
    // if (platform == 2) {
    return AWResponseModel.sendFailed("errorMsg");
    // }
  }

  ///购买安卓的商品
  static Future<AWResponseModel<AWPurchaseInfo>> purchaseAndroid(
      AWProduct product) async {
    // 需要把product解析成安卓需要的数据格式
    final androidString = product.toAndroidJson();
    var result =
        await _channel.invokeMethod('purchase', {"product": androidString});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final purchaseInfo = AWPurchaseInfo.fromAndroidJson(model.data);
    return AWResponseModel.sendSuccess(purchaseInfo);
  }

  ///获取有效订单列表
  static Future<AWResponseModel<List<AWPurchaseInfo>>> getOrderList(
      int platform) async {
    if (platform == 1) {
      return getAndroidOrderList();
    }
    //ios
    // if (platform == 2) {
    return AWResponseModel.sendFailed("errorMsg");
    // }
  }

  static Future<AWResponseModel<List<AWPurchaseInfo>>>
      getAndroidOrderList() async {
    var result = await _channel.invokeMethod('getOrderList');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }

    final List purchaseStr = model.data;
    final List<AWPurchaseInfo> purchaseList = [];
    purchaseStr.forEach((purchaseJson) {
      purchaseList.add(AWPurchaseInfo.fromAndroidJson(purchaseJson));
    });
    return AWResponseModel.sendSuccess(purchaseList);
  }

  ///获取历史订单列表
  static Future<AWResponseModel<List<AWPurchaseInfo>>> getHistoryOrderList(
      int platform) async {
    if (platform == 1) {
      return getAndroidHistoryOrderList();
    }
    //ios
    // if (platform == 2) {
    return AWResponseModel.sendFailed("errorMsg");
    // }
  }

  static Future<AWResponseModel<List<AWPurchaseInfo>>>
      getAndroidHistoryOrderList() async {
    var result = await _channel.invokeMethod('getHistoryOrderList');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }

    final List purchaseStr = model.data;
    final List<AWPurchaseInfo> purchaseList = [];
    purchaseStr.forEach((purchaseJson) {
      purchaseList.add(AWPurchaseInfo.fromAndroidJson(purchaseJson));
    });
    return AWResponseModel.sendSuccess(purchaseList);
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
}
