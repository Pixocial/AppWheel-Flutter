import 'dart:io';

import 'package:aw_purchase/model/aw_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aw_purchase/aw_purchase.dart';
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

  purchase() async {
    EasyLoading.show(status: "loading");
    if (product != null) {
      final response = await AwPurchase.purchase(1, product!);
      EasyLoading.dismiss(animation: true);
      if (response.result) {
        showToast("purchase success");
        isPurchase = true;
        setState(() {});
        return;
      }
      showToast("pruchase error:${response.msg}");
    }
  }

  Visibility getPurchaseBtn() {
    return Visibility(
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
        ),
        onPressed: () {
          purchase();
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => OrderList()));
        },
        child: const Text('查看订单'),
      ),
      visible: isPurchase,
    );
  }
}
