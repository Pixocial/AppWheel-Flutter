import 'dart:io';

import 'package:appwheel_flutter/model/aw_purchase_info.dart';
import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

class OrderDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new OrderDetailState();
  }
}

class OrderDetailState extends State<OrderDetail> {
  AWPurchaseInfo? orderInfo;

  @override
  Widget build(BuildContext context) {
    orderInfo = ModalRoute.of(context)?.settings.arguments as AWPurchaseInfo;
    return OKToast(
        child: Scaffold(
      appBar: AppBar(
        title: Text('product detail'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              //多嵌套一个 Expanded
              child: Container(
                child: Text(orderInfo?.toString() ?? "order error"),
              ),
            ),
            Container(
              //始终位于页面底部
              child: getRevokeView(),
            )
          ],
        ),
      ),
    ));
  }

  Widget getRevokeView() {
    //revoke just for android subs
    if (Platform.isAndroid && orderInfo?.paymentType == 1) {
      return Center(
        child: Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                refund();
              },
              child: const Text('refund'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                revoke();
              },
              child: const Text('revoke'),
            ),
          ],
        ),
      );
    } else {
      return Text("");
    }
  }

  revoke() async {
    EasyLoading.show(status: "loading");
    final res = await AwPurchase.revoke(orderInfo?.productId ?? "");
    EasyLoading.dismiss(animation: true);
    if (res.result) {
      showToast("revoke success");
      return;
    }
    showToast("revoke failed,${res.msg ?? ""}");
  }

  refund() async {
    EasyLoading.show(status: "loading");
    final res = await AwPurchase.refund(orderInfo?.productId ?? "");
    EasyLoading.dismiss(animation: true);
    if (res.result) {
      showToast("refund success");
      return;
    }
    showToast("refund failed,${res.msg ?? ""}");
  }
}
