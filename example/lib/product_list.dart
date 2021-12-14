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
  bool isRequestSuccess = false;
  bool requestFinish = false;

  ProductListState() {
    _requestProducts();
  }
  @override
  Widget build(BuildContext context) {
    this.context = context;
    if (!requestFinish) {
      EasyLoading.show(status: 'loading');
    }
    return OKToast(
        child: Scaffold(
      appBar: AppBar(
        title: Text('product list'),
      ),
      body: Center(
        child: createList(),
      ),
    ));
  }

  Widget createList() {
    if (!isRequestSuccess) {
      return Text("");
    }
    return ListView.builder(
        itemCount: productList.length,
        itemExtent: 40, //item的高度
        itemBuilder: (BuildContext context, int index) {
          return createItem(productList[index].productId);
        });
  }

  TextButton createItem(String productId) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 12),
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
      "pro_lifetime",
      "Leak",
      "Freeze",
      "Fade",
      "com.commsource.pomelo.timespackages"
    ];
  }

  _requestProducts() async {

    /// for android
    if (Platform.isAndroid) {
      var inappRes = await AWPurchase.requestProducts(
          AwPlatformType.android, "inapp", getAndroidInAppProducts());
      if (inappRes?.result == false) {
        showToast(inappRes?.msg ?? "request product error");
        EasyLoading.dismiss(animation: true);
        return;
      }
      if ((inappRes?.result ?? false) && inappRes?.data != null) {
        productList.addAll(inappRes?.data as List<AWProduct>);
      } else {
        if (AWCommonUtil.strNotEmpty(inappRes?.msg)) {
          showToast(inappRes?.msg as String);
        }
      }
      var subsRes = await AWPurchase.requestProducts(
          AwPlatformType.android, "subs", getAndroidSubsProducts());
      if (subsRes?.result == false) {
        showToast(subsRes?.msg ?? "request product error");
        EasyLoading.dismiss(animation: true);
        return;
      }
      if ((subsRes?.result ?? false) && subsRes?.data != null) {
        productList.addAll(subsRes?.data as List<AWProduct>);
      } else {
        if (AWCommonUtil.strNotEmpty(subsRes?.msg)) {
          showToast(subsRes?.msg as String);
        }
      }
    }
    EasyLoading.dismiss(animation: true);

    /// for ios
    if (Platform.isIOS) {
      var iosRes = await AWPurchase.requestProducts(
          AwPlatformType.ios, "", getIosProducts());
      requestFinish = true;
      EasyLoading.dismiss(animation: true);
      if (iosRes?.result == false) {
        showToast(iosRes?.msg ?? "request product error");
        return;
      }

      if (AWCommonUtil.strNotEmpty(iosRes?.msg)) {
        showToast(iosRes?.msg as String);
      }
      if ((iosRes?.result ?? false) && iosRes?.data != null) {
        productList.addAll(iosRes?.data as List<AWProduct>);
      } else {
        if (AWCommonUtil.strNotEmpty(iosRes?.msg)) {
          showToast(iosRes?.msg as String);
        }
      }
    }

    if (productList.length <= 0) {
      showToast("request productError");
      return;
    }
    showToast("request success");
    isRequestSuccess = true;
    setState(() {});
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
