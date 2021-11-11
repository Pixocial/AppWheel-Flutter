package com.example.aw_purchase

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.pixocial.purchases.Billing
import com.pixocial.purchases.Market
import com.pixocial.purchases.product.data.Product
import com.pixocial.purchases.product.listener.OnQueryProductListener
import com.pixocial.purchases.purchase.UserOrderManager
import com.pixocial.purchases.purchase.data.MTGPurchase
import com.pixocial.purchases.purchase.listener.*

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

/** AwPurchasePlugin */
class AwPurchasePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private var result: Result? = null
    private val TAG = "AWSDK";
    private val gson = Gson()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "aw_purchase")
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) =
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "init" -> {
                    initSDK(call, result)
                }
                "restore" -> {
                    restore(result)
                }
                "requestProducts" -> {
                    requestProducts(call, result)
                }
                "purchase" -> {
                    purchase(call, result)
                }
                "getOrderList" -> {
                    getOrderList(result)
                }
                "getHistoryOrderList" -> {
                    getHistoryOrderList(result)
                }
                "refund" -> {
                    refund(call,result)
                }
                "revoke" -> {
                    revoke(call,result)
                }
                else -> {
                    result.notImplemented()
                }
            }


    private fun initSDK(call: MethodCall, result: Result) {
        val appId = call.argument<String>("appId")
        val appUserId = call.argument<String>("appUserId")
        if (!appId.isNullOrEmpty()) {
            Billing.configure(context, appId, appUserId, object : OnBillingClientSetupFinishedListener() {
                override fun onBillingClientSetupFinished() {
                }

                override fun onPurchasesUpdated(resultCode: Int, purchases: MutableList<MTGPurchase>?) {

                }

                override fun onBillingSetupFinished(billingResponseCode: Int) {
                    if (billingResponseCode == 0) {
                        sendSuccess(result, null)
                        return
                    }
                    sendError(result, "init error,code:$billingResponseCode")
                }

            })
        } else {
            sendError(result, "init error,please set appId")
        }
    }

    private fun restore(result: Result) {
        Market.getInstance().restorePurchase(object : OnRestorePurchaseListener {
            override fun onSuccess(purchases: MutableList<MTGPurchase>?) {
                sendSuccess(result, purchases)
            }

            override fun onError(resultCode: Int) {
                sendError(result, "restore error,code$resultCode")
            }
        })
    }

    private fun requestProducts(call: MethodCall, result: Result) {
        val itemType = call.argument<String>("productType")
        val products = call.argument<List<String>>("products")
        Market.getInstance().getProductsInfo(itemType, products, object : OnQueryProductListener {
            override fun onSuccess(productInfo: MutableList<Product>?) {
                sendSuccess(result, productInfo)
            }

            override fun onError(resultCode: Int) {
                sendError(result, "request products error,code:$resultCode")
            }
        })
    }

    private fun purchase(call: MethodCall, result: Result) {
        val productString = call.argument<String>("product")
        if (!productString.isNullOrEmpty()) {
            val product = gson.fromJson<Product>(productString, Product::class.java)
            if (product == null) {
                sendError(result, "parse product error")
            }
            Market.getInstance().purchaseProduct(activity, product, object : InitiatePurchaseListener {
                override fun onVerifying(isVerifying: Boolean) {
                }

                override fun onPurchaseSuccess(purchase: MTGPurchase?) {
                    if (purchase != null) {
                        sendSuccess(result, purchase)
                        return
                    }
                    sendError(result, "the server parse token error")
                }

                override fun onOwnedGoods(purchase: MTGPurchase?) {
                    sendError(result, "purchase error,already owned")
                }

                override fun onPurchaseError(errorCode: Int) {
                    sendError(result, "purchase error,code:$errorCode")
                }
            })
            return
        }
        sendError(result, "purchase get product error")
    }

    /**
     * 获取有效订单
     */
    private fun getOrderList(result: Result) {
        return sendSuccess(result, UserOrderManager.getProvider().orders)
    }

    /**
     * 获取历史订单
     */
    private fun getHistoryOrderList(result: Result) {
        return sendSuccess(result, UserOrderManager.getProvider().historyOrders)
    }

    /**
     * 退款
     */
    private fun refund(call: MethodCall, result: Result) {
        val productId = call.argument<String>("productId")
        Market.getInstance().refund(productId, object : RevokeResponseListener {
            override fun onSuccess(resultCode: Int) {
                sendSuccess(result, true)
            }

            override fun onFail(resultCode: String?, msg: String?) {
                sendError(result, "refund error,msg:$msg,code:$resultCode")
            }
        })
    }

    ///退款
    private fun revoke(call: MethodCall, result: Result) {
        val productId = call.argument<String>("productId")
        if (productId.isNullOrEmpty()) {
            sendError(result, "refund error,productId is null")
            return
        }
        Market.getInstance().revoke(productId, object : RevokeResponseListener {
            override fun onSuccess(resultCode: Int) {
                sendSuccess(result, true)
            }

            override fun onFail(resultCode: String?, msg: String?) {
                sendError(result, "refund error,msg:$msg,code:$resultCode")
            }
        })
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    /**
     * 给flutter回调错误的结果
     */
    private fun sendError(result: Result, errorMsg: String) {
        result.success(gson.toJson(AWResponse(false, "", errorMsg)));
    }

    /**
     * 给flutter回调正确的结果
     */
    private fun <T> sendSuccess(result: Result, data: T) {
        if (data == null) {
            result.success(gson.toJson(AWResponse(true, "", "")))
            return
        }
        result.success(gson.toJson(AWResponse(true, data, "")))
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
}
