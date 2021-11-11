import 'package:aw_purchase/aw_purchase.dart';
import 'package:aw_purchase/model/aw_purchase_info.dart';
import 'package:aw_purchase_example/order_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

class OrderList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new OrderListState();
  }
}

class OrderListState extends State<OrderList> {
  List<AWPurchaseInfo> orderList = [];

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
    getOrderList();
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
    final orderListRes = await AwPurchase.getOrderList(1);
    final list = orderListRes.data ?? [];
    this.orderList = list;
    //请求到数据之后刷新界面
    setState(() {});
  }

  TextButton createItem(AWPurchaseInfo info) {
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
      child: Text("order id:" + info.orderId),
    );
  }

  restore() async {
    EasyLoading.show(status: "loading");
    final res = await AwPurchase.restore(1);
    EasyLoading.dismiss(animation: true);
    if (!res.result) {
      showToast(res.msg ?? "");
    }
    this.orderList = res.data ?? [];
    if (orderList.length > 0) {
      setState(() {});
      showToast("restore success");
    } else {
      showToast("restore success, but no data");
    }
  }
}
