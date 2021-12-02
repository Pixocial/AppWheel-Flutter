import 'package:appwheel_flutter/model/aw_order.dart';

/// 升降级的model
///DOC: https://developer.android.com/google/play/billing/subscriptions#proration
class UpOrDownGradeModel {
  late AWOrder oldOrder;

  ProrationMode profationMode = ProrationMode.immediateWithTimeProration;

  @override
  String toString() {
    return '{"oldSubsPurchase":"${oldOrder.toAndroidJson()}"'
    '"prorationMode":"$profationMode"'
        '}';
  }

}

///DOC: https://developer.android.com/google/play/billing/subscriptions#proration
enum ProrationMode {
  unknownSubscriptionUpgradeDowngradePolicy,
  immediateWithTimeProration,
  immediateAndChargeProratedPrice,
  immediateWithoutProration,
  deferred
}