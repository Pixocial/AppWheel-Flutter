import 'dart:io';

import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:appwheel_flutter/model/aw_product.dart';
import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:appwheel_flutter/util/aw_common_util.dart';
import 'package:appwheel_flutter_example/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

class ProductListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ProductListState();
  }
}

class ProductListState extends State<ProductListScreen> {
  final List<AWProduct> productList = [];
  List<String> skuIds = [];
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
      return ListView(
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
      return createList();
    }
  }

  ListView createList() {
    skuIds = getIosProducts();
    return ListView.builder(
        itemCount: skuIds.length,
        itemExtent: 40, //item的高度
        itemBuilder: (BuildContext context, int index) {
          return createItem(skuIds[index]);
        });
  }

  TextButton createItem(String productId) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        itemClick(productId);
      },
      child: Text(productId),
    );
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

  List<String> getIosProducts() {
    return [
      "com.commsource.pomelo.subscription.1year.test",
      "com.commsource.pomelo.subscription.1year.newuser",
      "com.commsource.pomelo.subscription.1year.newuser.test",
      "subscription_ye",
      "subscription_mo",
      "com.commsource.pomelo.subscription.1month.test",
      "com.commsource.pomelo.filterPack",
      "Brightness",
      "com.commsource.pomelo.lifetime.test",
      "Leak",
      "Freeze",
      "Fade",
      "com.commsource.pomelo.timespackages"
    ];
  }

  /// 进入详情页面
  void gotoDetail() {}

  _requestProducts() async {
    EasyLoading.show(status: 'loading');

    /// for android
    if (Platform.isAndroid) {
      var inappRes = await AwPurchase.requestProducts(
          AwPlatformType.android, "inapp", getAndroidInAppProducts());
      if ((inappRes?.result ?? false) && inappRes?.data != null) {
        productList.addAll(inappRes?.data as List<AWProduct>);
      } else {
        if (AWCommonUtil.strNotEmpty(inappRes?.msg)) {
          showToast(inappRes?.msg as String);
        }
      }
      var subsRes = await AwPurchase.requestProducts(
          AwPlatformType.android, "subs", getAndroidSubsProducts());

      if ((subsRes?.result ?? false) && subsRes?.data != null) {
        productList.addAll(subsRes?.data as List<AWProduct>);
      } else {
        if (AWCommonUtil.strNotEmpty(subsRes?.msg)) {
          showToast(subsRes?.msg as String);
        }
      }
    }

    /// for ios
    if (Platform.isIOS) {
      var iosRes = await AwPurchase.requestProducts(
          AwPlatformType.ios, "", getIosProducts());
      if ((iosRes?.result ?? false) && iosRes?.data != null) {
        productList.addAll(iosRes?.data as List<AWProduct>);
        // set productType,ios need user set productType for yourself
        final subs = [
          "com.commsource.pomelo.subscription.1year.test",
          "com.commsource.pomelo.subscription.1year.newuser",
          "com.commsource.pomelo.subscription.1year.newuser.test",
          "subscription_ye",
          "subscription_mo",
          "com.commsource.pomelo.subscription.1month.test",
          "com.commsource.pomelo.filterPack"
        ];
        final consumables = [
          "com.commsource.pomelo.timespackages"
        ];
        final nonConsumables = [
          "Brightness",
          "com.commsource.pomelo.lifetime.test",
          "Leak",
          "Freeze",
          "Fade"
        ];
        final nonRenewable = [
          "com.commsource.pomelo.filterPack"
        ];
        productList.forEach((pro) {
          if(consumables.contains( pro.productId)){
            pro.productType = "0";
          }
        });
        productList.forEach((pro) {
          if(nonConsumables.contains( pro.productId)){
            pro.productType = "1";
          }
        });
        productList.forEach((pro) {
          if(subs.contains( pro.productId)){
            pro.productType = "2";
          }
        });
        productList.forEach((pro) {
          if(nonRenewable.contains( pro.productId)){
            pro.productType = "3";
          }
        });
      } else {
        if (AWCommonUtil.strNotEmpty(iosRes?.msg)) {
          showToast(iosRes?.msg as String);
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
