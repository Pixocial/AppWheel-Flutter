import 'dart:io';

import 'package:appwheel_flutter/model/aw_base_respon_model.dart';
import 'package:appwheel_flutter/model/aw_order.dart';
import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

import 'order_detail.dart';

class HistoryOrderList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HistoryOrderListState();
  }
}

class HistoryOrderListState extends State<HistoryOrderList> {
  List<AWOrder> orderList = [];
  HistoryOrderListState() {
    getOrderList();
  }
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: Scaffold(
      appBar: AppBar(
        title: Text('history order detail'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              //多嵌套一个 Expanded
              child: Container(
                child: createList(),
              ),
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
      orderListRes = await AWPurchase.getHistoryOrderList(AwPlatformType.ios);
    }
    if (Platform.isAndroid) {
      orderListRes = await AWPurchase.getHistoryOrderList(AwPlatformType.android);
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
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetail(),
              settings: RouteSettings(arguments: info),
            ));
      },
      child: Text("${info.productId}"),
    );
  }


}
