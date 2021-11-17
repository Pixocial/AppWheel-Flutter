// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';

import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:appwheel_flutter/util/aw_common_util.dart';
import 'package:flutter/services.dart';

import 'model/aw_base_respon_model.dart';
import 'model/aw_parse_native_model.dart';
import 'model/aw_product.dart';
import 'model/aw_purchase_info.dart';

class AwPurchase {
  static const MethodChannel _channel = MethodChannel('appwheel_flutter');

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
  static Future<AWResponseModel<List<AWPurchaseInfo>>?> restore(
      AwPlatformType type) async {
    if (type == AwPlatformType.android) {
      return androidRestore();
    }
    if (type == AwPlatformType.ios) {
      return iosRestore();
    }
  }

  static Future<AWResponseModel<List<AWPurchaseInfo>>> androidRestore() async {
    var result = await _channel.invokeMethod('restore');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWPurchaseInfo> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    final List purchaseStr = model.data;
    purchaseStr.forEach((purchaseJson) {
      purchaseList.add(AWPurchaseInfo.fromAndroidJson(purchaseJson));
    });
    return AWResponseModel.sendSuccess(purchaseList);
  }

  static Future<AWResponseModel<List<AWPurchaseInfo>>> iosRestore() async {
    var result = await _channel.invokeMethod('restore');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWPurchaseInfo> purchaseList = [];
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
    productsStr.forEach((productJson) {
      productList.add(AWProduct.fromAndroidJson(productJson));
    });
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
    productsStr.forEach((productJson) {
      productList.add(AWProduct.fromIosJson(productJson));
    });
    return AWResponseModel.sendSuccess(productList);
  }

  /// 购买商品
  /// platform 平台，1：Android，2：iOS
  static Future<AWResponseModel<AWPurchaseInfo>?> purchase(
      AwPlatformType type, AWProduct product) async {
    if (type == AwPlatformType.android) {
      return purchaseAndroid(product);
    }
    if (type == AwPlatformType.ios) {
      return purchaseIos(product);
    }
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
  ///购买安卓的商品
  static Future<AWResponseModel<AWPurchaseInfo>> purchaseIos(
      AWProduct product) async {
    // 需要把product解析成安卓需要的数据格式
    final iosString = product.toIosJson();
    var result =
        await _channel.invokeMethod('purchase', {"product": iosString});
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final purchaseInfo = AWPurchaseInfo.fromIosJson(model.data);
    return AWResponseModel.sendSuccess(purchaseInfo);
  }

  ///获取有效订单列表
  static Future<AWResponseModel<List<AWPurchaseInfo>>?> getOrderList(
      AwPlatformType type) async {
    if (type == AwPlatformType.android) {
      return getAndroidOrderList();
    }
    if (type == AwPlatformType.ios) {
      return getIosOrderList();
    }
  }

  static Future<AWResponseModel<List<AWPurchaseInfo>>>
      getAndroidOrderList() async {
    var result = await _channel.invokeMethod('getOrderList');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWPurchaseInfo> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    final List purchaseStr = model.data;
    purchaseStr.forEach((purchaseJson) {
      purchaseList.add(AWPurchaseInfo.fromAndroidJson(purchaseJson));
    });
    return AWResponseModel.sendSuccess(purchaseList);
  }

  static Future<AWResponseModel<List<AWPurchaseInfo>>> getIosOrderList() async {
    var result = await _channel.invokeMethod('getOrderList');
    final model = getResponseModel(result);
    if (!model.result) {
      return AWResponseModel.sendFailed(model.msg);
    }
    final List<AWPurchaseInfo> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    return parseIosOrder(model.data, purchaseList);
  }

  ///获取历史订单列表
  static Future<AWResponseModel<List<AWPurchaseInfo>>> getHistoryOrderList(
      AwPlatformType type) async {
    if (type == AwPlatformType.android) {
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
    final List<AWPurchaseInfo> purchaseList = [];
    if (model.data == null) {
      return AWResponseModel.sendSuccess(purchaseList);
    }
    final List purchaseStr = model.data;
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

  ///解析iOS返回的订单数据：供订单列表和恢复购买使用的统一方法
  static Future<AWResponseModel<List<AWPurchaseInfo>>> parseIosOrder(
      dynamic purchaseData, List<AWPurchaseInfo> purchaseList) async {
    //订阅
    final List subs = purchaseData["subs"] ?? [];
    subs.forEach((purchaseJson) {
      purchaseList.add(AWPurchaseInfo.fromIosJson(purchaseJson));
    });

    //消耗品、非消耗品、非续期订阅
    final List inapps = purchaseData["inapps"] ?? [];
    inapps.forEach((purchaseJson) {
      purchaseList.add(AWPurchaseInfo.fromIosJson(purchaseJson));
    });
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
}
