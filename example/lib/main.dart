
import 'dart:io';

import 'package:appwheel_flutter/model/aw_base_respon_model.dart';
import 'package:appwheel_flutter/model/aw_order.dart';
import 'package:appwheel_flutter_example/product_list.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:appwheel_flutter/aw_observer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

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
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _init();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await AWPurchase.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('AW purchase Demo'),
            ),
            body: MyStatelessWidget(),
          ),
          builder: EasyLoading.init(),
        ));
  }


}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget implements AWObserver{
  MyStatelessWidget({Key? key}) : super(key: key){

    AWPurchase.setObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
        ],
      ),
    );
  }

  @override
  void onPurchased(List<AWOrder> list) {
    showToast("onPurchasedUpdate");
  }
}

/// 初始化
void _init() async {
  AWResponseModel? res;
  if(Platform.isAndroid) {
    res = await AWPurchase.init("166", "hykTest");
  }
  if (Platform.isIOS) {
    res = await AWPurchase.init("121", "hykTest");
  }
  if (!(res?.result??false)) {
    showToast(
      res?.msg as String,
      duration: Duration(seconds: 2),
      position: ToastPosition.bottom,
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 13.0,
      textStyle: TextStyle(fontSize: 18.0),
    );
  } else {
    showToast(
      "init success",
      duration: Duration(seconds: 2),
      position: ToastPosition.bottom,
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 13.0,
      textStyle: TextStyle(fontSize: 18.0),
    );
  }
}
