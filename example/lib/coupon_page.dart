
import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:appwheel_flutter/model/aw_coupon_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class CouponPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new CouponPageState();
  }
}

class CouponPageState extends State<CouponPage> {
  
  String couponString = "";
  AWCouponModel? model;
  
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: Scaffold(
          appBar: AppBar(
            title: Text('coupon'),
          ),
          body: Center(
            child: Column(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    queryCoupon();
                  },
                  child: const Text('请求优惠券'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    updateCoupon();
                  },
                  child: const Text('消耗优惠券'),
                ),
                Text(couponString)
              ],
            ),
          ),
        ));
  }

  queryCoupon() async {
    final res = await AWPurchase.queryCoupon();
    model = res.data;
    if (!res.result || model == null) {
      showToast(res.msg ?? "unknow error");
    }
    couponString = model.toString();
    setState(() {
      
    });
  }

  updateCoupon() async {
      final res = await AWPurchase.updateCoupon(model?.taskId ?? 0);
      if (!res.result) {
        showToast("更新失败；${res.msg??""}");
        return;
      }
      showToast("更新成功");
  }
}
