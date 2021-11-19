import 'package:appwheel_flutter/aw_purchase.dart';

import 'aw_platform_type.dart';
import 'model/aw_base_respon_model.dart';
import 'model/aw_order.dart';

///集合购买数据的类
class AWPurchaseInfo {
  ///返回当前有效的订阅中订阅期限最长的
  Future<AWOrder?> getCurrentSubs(AwPlatformType type) async {
    var orderRes = await AWPurchase.getOrderList(type);
    if (false == (orderRes?.result ?? false)) {
      return null;
    }
    final orderList = orderRes?.data ?? [];
    if (orderList.isEmpty) {
      return null;
    }
    AWOrder? currentSubs;
    if (type == AwPlatformType.ios) {
      int expireTime = 0;
      for (var order in orderList) {
        if (order.productType == IosProductType.renewable) {
          if ((order.expireTime ?? 0) >= expireTime) {
            //筛选最后到期的一个
            currentSubs = order;
          }
        }
      }
    }
    if (type == AwPlatformType.android) {
      int expireTime = 0;
      for (var order in orderList) {
        if (order.paymentType == AndroidProductType.subs) {
          if ((order.expireTime ?? 0) >= expireTime) {
            //筛选最后到期的一个
            currentSubs = order;
          }
        }
      }
    }
    return currentSubs;
  }
  /// 获取历史订单
  Future<AWResponseModel<List<AWOrder>>?> getHistoryOrders(AwPlatformType type) async {
    return AWPurchase.getHistoryOrderList(type);
  }
  ///获取有效订单
  Future<AWResponseModel<List<AWOrder>>?> getOrders(AwPlatformType type) async {
    return AWPurchase.getOrderList(type);
  }

}
