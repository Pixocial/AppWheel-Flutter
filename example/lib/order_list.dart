import 'dart:io';

import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:appwheel_flutter/model/aw_base_respon_model.dart';
import 'package:appwheel_flutter/model/aw_order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

import 'order_detail.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OrderListState();
  }
}

class OrderListState extends State<OrderList> with WidgetsBindingObserver {
  List<AWOrder> orderList = [];


  OrderListState() {
    getOrderList();
  }


  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: Scaffold(
      appBar: AppBar(
        title: Text('order list detail'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              //多嵌套一个 Expanded
              child: Container(
                child: createList(),
              ),
            ),
            Container(
              //始终位于页面底部
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  restore();
                },
                child: const Text('恢复购买'),
              ),
              padding: const EdgeInsets.only(bottom: 20)
            )
          ],
        ),
      ),
      // Column(
      //   children: [createList()],
      // ),
    ));
  }

  Widget createList() {
    if (orderList.length <= 0) {
      return Text("No Data");
    }
    return ListView.builder(
        itemCount: orderList.length,
        itemExtent: 40, //item的高度
        itemBuilder: (BuildContext context, int index) {
          return createItem(orderList[index]);
        });
  }

  getOrderList() async {
    AWResponseModel? orderListRes;
    if (Platform.isIOS) {
      orderListRes = await AWPurchase.getOrderList(AwPlatformType.ios);
    }
    if (Platform.isAndroid) {
      orderListRes = await AWPurchase.getOrderList(AwPlatformType.android);
    }
    if (!(orderListRes?.result?? false)){
      showToast(orderListRes?.msg ??"");
      return;
    }
    final list = orderListRes?.data ?? [];
    this.orderList = list;

    //请求到数据之后刷新界面
    setState(() {});
  }

  TextButton createItem(AWOrder info) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetail(),
              settings: RouteSettings(arguments: info),
            ));
      },
      child: Text(info.productId),
    );
  }

  restore() async {
    EasyLoading.show(status: "loading");
    AWResponseModel? res;
    if (Platform.isAndroid) {
      res = await AWPurchase.restore(AwPlatformType.android);
    }
    if (Platform.isIOS) {
      res = await AWPurchase.restore(AwPlatformType.ios);
    }
    EasyLoading.dismiss(animation: true);
    if (!(res?.result ?? false)) {
      showToast(res?.msg ?? "");
      return;
    }
    this.orderList = res?.data ?? [];
    if (orderList.length > 0) {
      setState(() {});
      showToast("restore success");
    } else {
      showToast("restore success, but no data");
    }
  }
}
