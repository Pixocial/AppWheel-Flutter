import 'dart:io';

import 'package:aw_purchase/model/aw_product.dart';
import 'package:aw_purchase/util/aw_common_util.dart';
import 'package:aw_purchase_example/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:aw_purchase/aw_purchase.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

class ProductListScreen extends StatelessWidget {
  final List<AWProduct> productList = [];
  late BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return OKToast(
        child: Scaffold(
      appBar: AppBar(
        title: Text('product list'),
      ),
      body: Center(
        child: getListView(),
      ),
    ));
  }

  ListView getListView() {
    _requestProducts();
    if (Platform.isAndroid) {
      return new ListView(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.unlock_bokeh');
            },
            child: const Text('com.meitu.airbrush.vivo.unlock_bokeh'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample_1we');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample_1we'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample_4we');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample_4we'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample_1mo');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample_1mo'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample_3mo');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample_3mo'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample_6mo');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample_6mo'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample_12mo');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample_12mo'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample_1we');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample_1we'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample002_4we');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample002_4we'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              itemClick('com.meitu.airbrush.vivo.subs_sample002_1mo');
            },
            child: const Text('com.meitu.airbrush.vivo.subs_sample002_1mo'),
          ),
        ],
      );
    } else {
      ///iOS的sku
      return new ListView(
        children: [],
      );
    }
  }

  List<String> getAndroidInAppProducts() {
    return ["com.meitu.airbrush.vivo.unlock_bokeh"];
  }

  List<String> getAndroidSubsProducts() {
    return [
      "com.meitu.airbrush.vivo.subs_sample_1we",
      "com.meitu.airbrush.vivo.subs_sample_4we",
      "com.meitu.airbrush.vivo.subs_sample_1mo",
      "com.meitu.airbrush.vivo.subs_sample_3mo",
      "com.meitu.airbrush.vivo.subs_sample_6mo",
      "com.meitu.airbrush.vivo.subs_sample_12mo",
      "com.meitu.airbrush.vivo.subs_sample_1we",
      "com.meitu.airbrush.vivo.subs_sample002_4we",
      "com.meitu.airbrush.vivo.subs_sample002_1mo"
    ];
  }

  /// 进入详情页面
  void gotoDetail() {}

  _requestProducts() async {
    EasyLoading.show(status: 'loading');
    if (Platform.isAndroid) {
      var inappRes = await AwPurchase.requestProducts(
          1, "inapp", getAndroidInAppProducts());
      if (inappRes.result && inappRes.data != null) {
        productList.addAll(inappRes.data as List<AWProduct>);
      } else {
        if (AWCommonUtil.strNotEmpty(inappRes.msg)) {
          showToast(inappRes.msg as String);
        }
      }
      var subsRes =
          await AwPurchase.requestProducts(1, "subs", getAndroidSubsProducts());

      if (subsRes.result && subsRes.data != null) {
        productList.addAll(subsRes.data as List<AWProduct>);
      } else {
        if (AWCommonUtil.strNotEmpty(subsRes.msg)) {
          showToast(subsRes.msg as String);
        }
      }
    }
    EasyLoading.dismiss(animation: true);
    if (productList.length <= 0) {
      showToast("request productError");
      return;
    }
    showToast("request success");
  }

  void itemClick(String productId) {
    productList.forEach((element) {
      if (element.productId == productId) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(),
              settings: RouteSettings(arguments: element),
            ));
      }
    });
  }
}
