import 'dart:io';

import 'package:appwheel_flutter/model/aw_base_respon_model.dart';
import 'package:appwheel_flutter/model/aw_order.dart';
import 'package:appwheel_flutter_example/coupon_page.dart';
import 'package:appwheel_flutter_example/product_list.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:appwheel_flutter/aw_observer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history_order_list.dart';
import 'order_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('AW purchase Demo'),
            ),
            body: MyStatefulWidget(),
          ),
          builder: EasyLoading.init(),
        ),
        duration: Duration(seconds: 3));
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyStatefulWidgetState();
  }
}

class MyStatefulWidgetState extends State<MyStatefulWidget>
    implements AWObserver {
  String userId = "hykTest";
  final TextEditingController _controller = TextEditingController();

  MyStatefulWidgetState() {
    _init();
    getUserId();
    AWPurchase.setObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: TextEditingController()..text = userId,
            decoration: const InputDecoration(
              hintText: "userId",
            ),
            onChanged: (v) {
              userId = v;
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              _init();
            },
            child: const Text('init'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              //跳转到第二页面
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProductListScreen()));
            },
            child: const Text('商品列表'),
          ),
          const SizedBox(height: 30),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryOrderList()));
            },
            child: const Text('我的历史订单'),
          ),
          const SizedBox(height: 30),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OrderList()));
            },
            child: const Text('有效订单'),
          ),
          const SizedBox(height: 30),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              couponClick(context);
            },
            child: const Text('优惠券'),
          ),
        ],
      ),
    );
  }

  @override
  void onPurchased(List<AWOrder> list) {
    // showToast("onPurchasedUpdate");
  }

  void couponClick(BuildContext context) {
    if (Platform.isIOS) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CouponPage()));
      return;
    }
    showToast("只有iOS能用");
  }

  /// 初始化
  void _init() async {
    AWResponseModel? res;
    if (Platform.isAndroid) {
      res = await AWPurchase.init("166", userId);
    }
    if (Platform.isIOS) {
      res = await AWPurchase.init("121", userId);
    }
    if (res?.result == true) {
      print("启动的userid:$userId");
      showToast("init success");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      print("userId:$userId");
      prefs.setString("userId", userId);
      return;
    }
    showToast(res?.msg ?? "init error unknow");
  }

  void getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId") ?? "hykTest";
    setState(() {
      userId = prefs.getString("userId") ?? "hykTest";
    });
  }
}
