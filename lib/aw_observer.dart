import 'package:appwheel_flutter/model/aw_order.dart';

abstract class AWObserver {
  void onPurchased(List<AWOrder> list);
}