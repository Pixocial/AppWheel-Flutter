package com.example.appwheel_flutter;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.pixocial.purchases.Billing;
import com.pixocial.purchases.Market;
import com.pixocial.purchases.product.data.Product;
import com.pixocial.purchases.product.listener.OnQueryProductListener;
import com.pixocial.purchases.purchase.UserOrderManager;
import com.pixocial.purchases.purchase.data.MTGPurchase;
import com.pixocial.purchases.purchase.listener.InitiatePurchaseListener;
import com.pixocial.purchases.purchase.listener.OnBillingClientSetupFinishedListener;
import com.pixocial.purchases.purchase.listener.OnRestorePurchaseListener;
import com.pixocial.purchases.purchase.listener.OrderObserver;
import com.pixocial.purchases.purchase.listener.RevokeResponseListener;

import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AppwheelFlutterPlugin
 */
public class AppwheelFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;
    private Activity activity;
    private Result Result;
    private final String TAG = "AWSDK";
    private Gson gson = new Gson();


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "appwheel_flutter");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        addObserver();
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//        if (call.method.equals("getPlatformVersion")) {
//            result.success("Android " + android.os.Build.VERSION.RELEASE);
//        } else {
//            result.notImplemented();
//        }

        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "init":
                initSDK(call, result);
                break;
            case "restore":
                restore(result);
                break;
            case "requestProducts":
                requestProducts(call, result);
                break;
            case "purchase":
                purchase(call, result);
                break;
            case "getOrderList":
                getOrderList(result);
                break;
            case "getHistoryOrderList":
                getHistoryOrderList(result);
                break;
            case "refund":
                refund(call, result);
                break;
            case "revoke":
                revoke(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }

    }

    private void initSDK(MethodCall call, Result result) {
        String appId = call.argument("appId");
        String appUserId = call.argument("appUserId");
        if (!isNullOrEmpty(appId)) {
            Billing.configure(context, appId, appUserId, new OnBillingClientSetupFinishedListener() {
                @Override
                public void onBillingSetupFinished(int billingResponseCode) {
                    if (billingResponseCode == 0) {
                        sendSuccess(result, null);
                        return;
                    }
                    sendError(result, "init error,code:$billingResponseCode");
                }
            });
        } else {
            sendError(result, "init error,please set appId");
        }
    }

    private void restore(Result result) {
        Market.getInstance().restorePurchase(new OnRestorePurchaseListener() {
            @Override
            public void onSuccess(List<MTGPurchase> purchases) {
                sendSuccess(result, purchases);
            }

            @Override
            public void onError(int resultCode) {
                sendError(result, "restore error,code$resultCode");

            }
        });
    }

    private void requestProducts(MethodCall call, Result result) {
        Log.i(TAG, "调用了请求商品");
        String itemType = call.argument("productType");
        List<String> products = call.argument("products");
        Market.getInstance().getProductsInfo(itemType, products, new OnQueryProductListener() {
            @Override
            public void onSuccess(List<Product> productInfo) {
                sendSuccess(result, productInfo);

            }

            @Override
            public void onError(int resultCode) {
                sendError(result, "request products error,code:$resultCode");

            }
        });
    }

    private void purchase(MethodCall call, Result result) {
        String productString = call.argument("product");
        if (!isNullOrEmpty(productString)) {
            Product product = gson.fromJson(productString, Product.class);
            if (product == null) {
                sendError(result, "parse product error");
            }
            Market.getInstance().purchaseProduct(activity, product, new InitiatePurchaseListener() {
                @Override
                public void onVerifying(boolean isVerifying) {

                }

                @Override
                public void onPurchaseSuccess(MTGPurchase purchase) {
                    if (purchase != null) {
                        sendSuccess(result, purchase);
                        return;
                    }
                    sendError(result, "the server parse token error");
                }

                @Override
                public void onOwnedGoods(MTGPurchase purchase) {

                    sendError(result, "purchase error,already owned");
                }

                @Override
                public void onPurchaseError(int errorCode) {

                    sendError(result, "purchase error,code:$errorCode");
                }
            });
            return;
        }
        sendError(result, "purchase get product error");
    }

    /**
     * 获取有效订单
     */
    private void getOrderList(Result result) {
        sendSuccess(result, UserOrderManager.getProvider().getOrders());
    }

    /**
     * 获取历史订单
     */
    private void getHistoryOrderList(Result result) {
        sendSuccess(result, UserOrderManager.getProvider().getHistoryOrders());
    }

    /**
     * 退款
     */
    private void refund(MethodCall call, Result result) {
        String productId = call.argument("productId");
        Market.getInstance().refund(productId, new RevokeResponseListener() {
            @Override
            public void onSuccess(int resultCode) {

                sendSuccess(result, true);
            }

            @Override
            public void onFail(String resultCode, String msg) {

                sendError(result, "refund error,msg:$msg,code:$resultCode");
            }
        });
    }

    ///退款
    private void revoke(MethodCall call, Result result) {
        String productId = call.argument("productId");
        if (isNullOrEmpty(productId)) {
            sendError(result, "refund error,productId is null");
            return;
        }
        Market.getInstance().revoke(productId, new RevokeResponseListener() {
            @Override
            public void onSuccess(int resultCode) {

                sendSuccess(result, true);
            }

            @Override
            public void onFail(String resultCode, String msg) {

                sendError(result, "revoke error,msg:$msg,code:$resultCode");
            }
        });
    }


    /**
     * 给flutter回调错误的结果
     */
    private void sendError(Result result, String errorMsg) {
        result.success(gson.toJson(new AWResponse(false, "", errorMsg)));
    }

    /**
     * 给flutter回调正确的结果
     */
    private <T> void sendSuccess(Result result, T data) {
//        if (data == null) {
//            result.success(gson.toJson(new AWResponse(true, "", "")));
//            return;
//        }
        result.success(gson.toJson(new AWResponse(true, data, "")));
    }

    private boolean isNullOrEmpty(String str) {
        return str == null || str.length() <= 0;
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    /**
     * 接收统一事件的监听
     */
    private void addObserver() {
        UserOrderManager.getProvider().addPurchaseObserver(new OrderObserver() {
            @Override
            public void onUpdateOrders(List<MTGPurchase> purchases) {
                HashMap<String, Object> map = new HashMap();
                map.put("platform", 0);
                map.put("orderList", purchases);
                channel.invokeMethod("onPurchased", gson.toJson(map));
            }
        });
    }
}
