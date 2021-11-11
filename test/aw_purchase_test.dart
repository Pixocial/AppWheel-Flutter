import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aw_purchase/aw_purchase.dart';

void main() {
  const MethodChannel channel = MethodChannel('aw_purchase');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AwPurchase.platformVersion, '42');
  });
}
