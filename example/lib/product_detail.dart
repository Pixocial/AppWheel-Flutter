import 'dart:io';

import 'package:appwheel_flutter/aw_purchase.dart';
import 'package:appwheel_flutter/model/aw_base_respon_model.dart';
import 'package:appwheel_flutter/model/aw_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:appwheel_flutter/aw_platform_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';

import 'order_list.dart';

class ProductDetailScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ProductDetailState();
  }
}

class ProductDetailState extends State<ProductDetailScreen> {
  AWProduct? product;
  late Visibility purchaseBtn;
  late Visibility gotoOrderBtn;
  late Opacity btn;
  bool isPurchase = false;

  @override
  Widget build(BuildContext context) {
    product = ModalRoute.of(context)?.settings.arguments as AWProduct;
    purchaseBtn = getPurchaseBtn();
    gotoOrderBtn = getGotoOrderBtn();
    return OKToast(
        child: Scaffold(
      appBar: AppBar(
        title: Text('product detail'),
      ),
      body: Center(
        child: Column(
          children: [Text(product.toString()), purchaseBtn, gotoOrderBtn],
        ),
      ),
    ));
  }

  purchase({AWProductDiscount? discount}) async {
    EasyLoading.show(status: "loading");
    if (product != null) {
      AWResponseModel? response;
      //pruchase android product
      if (Platform.isAndroid) {
        response = await AWPurchase.purchase(AwPlatformType.android, product!);
      }
      // purchase ios product
      if (Platform.isIOS) {
        response = await AWPurchase.purchase(AwPlatformType.ios, product!,
            productType: getProductType(product?.productId ?? ""), quantity: 1,discount: discount);
      }
      EasyLoading.dismiss(animation: true);
      if (response?.result ?? false) {
        showToast("purchase success");
        isPurchase = true;
        setState(() {});
        return;
      }
      showToast("pruchase error:${response?.msg}");
    }
  }

  Visibility getPurchaseBtn() {
    return Visibility(
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
        ),
        onPressed: () {
          if (getProductType(product?.productId ?? "") == AWProduct.autoRenewableProductType) {
            showDiscountDialog();
          } else {
            purchase();
          }
        },
        child: const Text('购买'),
      ),
      visible: !isPurchase,
    );
  }

  Visibility getGotoOrderBtn() {
    return Visibility(
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => OrderList()));
        },
        child: const Text('查看订单'),
      ),
      visible: isPurchase,
    );
  }

  ///discount
  void showDiscountDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        var child = Column(
          mainAxisSize: MainAxisSize.min,
          //设置dialog居中,配合listview的,shrinkWrap: true,一起使用
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
                purchase(); //购买原价
              },
              child: const Text('normal price'),
            ),
            getDiscountList(),
          ],
        );
        return Dialog(child: child);
      },
    );
  }

  Widget getDiscountList() {
    final List<AWProductDiscount> discounts = product?.discounts ?? [];
    if (discounts.isEmpty == true) {
      return const Text("");
    }
    return ListView.builder(
      itemCount: discounts.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(discounts[index].discountId ?? ""),
          onTap: () => {
            Navigator.pop(context),
            purchase(discount: discounts[index])}
              ,
        );
      },
    );
  }

  String getProductType(String productId) {
    final subs = [
      "com.commsource.pomelo.subscription.1year.test",
      "com.commsource.pomelo.subscription.1year.newuser",
      "com.commsource.pomelo.subscription.1year.newuser.test",
      "subscription_ye",
      "subscription_mo",
      "com.commsource.pomelo.subscription.1month.test",
      "com.commsource.pomelo.filterPack"
    ];
    final consumables = ["com.commsource.pomelo.timespackages"];
    final nonConsumables = [
      "Brightness",
      "com.commsource.pomelo.lifetime.test",
      "pro_lifetime",
      "Leak",
      "Freeze",
      "Fade"
    ];
    final nonRenewable = ["com.commsource.pomelo.filterPack"];
    if (consumables.contains(productId)) {
      return "0";
    }
    if (nonConsumables.contains(productId)) {
      return "1";
    }
    if (subs.contains(productId)) {
      return "2";
    }
    if (nonRenewable.contains(productId)) {
      return "3";
    }
    return "";
  }
}
