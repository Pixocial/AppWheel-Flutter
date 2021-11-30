#import "AppwheelFlutterPlugin.h"
#import <PurchaseSDK/AWPurchaseKit.h>
#import "NSObject+aw.h"
#import "NSObject+YYModel.h"

@interface AppwheelFlutterPlugin()<AWPurchaseObserver>

@property (nonatomic, retain) FlutterMethodChannel *channel;

@end

@implementation AppwheelFlutterPlugin

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    self = [super init];
    
    self.channel = channel;
    
    [AWPurchaseKit addPurchaseObserver:self];
    
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"appwheel_flutter"
            binaryMessenger:[registrar messenger]];
    AppwheelFlutterPlugin *instance = [[AppwheelFlutterPlugin alloc] initWithChannel:channel registrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSDictionary *arguments = call.arguments;
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"init" isEqualToString:call.method]) {
        [self initSDK:arguments result:result];
    } else if ([@"restore" isEqualToString:call.method]) {
        [self restore:arguments result:result];
    } else if ([@"requestProducts" isEqualToString:call.method]) {
        [self requestProducts:arguments result:result];
    } else if ([@"purchase" isEqualToString:call.method]) {
        [self purchase:arguments result:result];
    } else if ([@"getOrderList" isEqualToString:call.method]) {
        [self getOrderList:arguments result:result];
    } else if ([@"getHistoryOrderList" isEqualToString:call.method]) {
        [self getHistoryOrderList:arguments result:result];
    } else if ([@"queryCoupon" isEqualToString:call.method]) {
        [self queryCoupon:arguments result:result];
    } else if ([@"updateCoupon" isEqualToString:call.method]) {
        [self updateCoupon:arguments result:result];
    }


   else {
    result(FlutterMethodNotImplemented);
  }
}


- (void)initSDK:(NSDictionary*)arguments
         result:(FlutterResult)result {
    int appId = [arguments[@"appId"] intValue];
    NSString *userId = arguments[@"userId"];
    
    [AWPurchaseKit configureWithAppId:appId uid:userId completion:^(BOOL success, AWError * _Nonnull error) {
        if (!success) {
            [self sendError:result withMsg:error.description];
            return;
        }
        [self sendSuccess:result withData:nil];
            
    }];
}

- (void)restore:(NSDictionary*)arguments
         result:(FlutterResult)result {
    [AWPurchaseKit restorePurchaseWithCompletion:^(BOOL isInSubscriptionPeriod, NSArray * _Nonnull validSubscriptions, NSArray * _Nonnull restoredPurchasedItems, AWError * _Nonnull error) {
        if (error && error.errorCode != AWErrorTypeUnknown && error.errorCode != AWErrorTypeSubscriptionExpiredInReceipt) {
            [self sendError:result withMsg:error.description];
            return;
        }
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        //单项
        dic[@"inapps"] = [[AWPurchaseKit getPurchaseInfo] purchasedArray];
        
        //订阅
        dic[@"subs"] =  [[AWPurchaseKit getPurchaseInfo] getValidSubscriptions];
        
        [self sendSuccess:result withData:dic];
        
    }];
}
- (void)requestProducts:(NSDictionary*)arguments
         result:(FlutterResult)result {
    NSSet *products = arguments[@"products"];
    [AWPurchaseKit getProductsInfoWithProductIdentifiers:products completion:^(RetrievedProducts * _Nonnull retrievedProducts) {
        if (retrievedProducts.error) {
            [self sendError:result withMsg:retrievedProducts.error.errorMessage];
            return;
        }
        [self sendSuccess:result withData:retrievedProducts];
        
    }];
}
- (void)purchase:(NSDictionary*)arguments
         result:(FlutterResult)result {
    AWProduct *product = [AWProduct yy_modelWithJSON:arguments[@"product"]];

    if (product) {
        if (!product.productIdentifier) {
            [self sendError:result withMsg:@"productId can not be null"];
            return;
        }
        [AWPurchaseKit purchaseProductWithProductIdentifier:product.productIdentifier quantity:1 productType:product.productType completion:^(BOOL success, AWError * _Nonnull error) {
            if (!success) {
                [self sendError:result withMsg:error.description];
                return;
            }
            //从订单中把当前的订单返回
            if (product.productType == 2) {
                LatestSubscriptionInfo *currentInfo;
                for (LatestSubscriptionInfo *info in [[AWPurchaseKit getPurchaseInfo]getCurrentValidSubscriptions]) {
                    if ([info.productIdentifier isEqualToString:product.productIdentifier]) {
                        currentInfo = info;
                        break;
                    }
                }
                
                [self sendSuccess:result withData:currentInfo];
            }
            PurchasedProduct *currentOrder;
            for (PurchasedProduct *product in [[AWPurchaseKit getPurchaseInfo] purchasedArray]) {
                if ([product.productIdentifier isEqualToString:product.productIdentifier]) {
                    currentOrder = product;
                    break;
                }
            }
            
            [self sendSuccess:result withData:currentOrder];
        }];
    } else {
        [self sendError:result withMsg:@"productId can not be null"];
    }
}

- (void)getOrderList:(NSDictionary*)arguments
         result:(FlutterResult)result {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //单项
    dic[@"inapps"] = [[AWPurchaseKit getPurchaseInfo] purchasedArray];
    
    //订阅
    dic[@"subs"] =  [[AWPurchaseKit getPurchaseInfo] getValidSubscriptions];
    [self sendSuccess:result withData:dic];
    
}

- (void)getHistoryOrderList:(NSDictionary*)arguments
         result:(FlutterResult)result {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //单项
    dic[@"inapps"] = [[AWPurchaseKit getPurchaseInfo] purchasedArray];

    //订阅
    dic[@"subs"] =  [[AWPurchaseKit getPurchaseInfo] getAllSubscriptionsInfo];
    [self sendSuccess:result withData:dic];
}

/// 请求优惠券
- (void)queryCoupon:(NSDictionary*)arguments
         result:(FlutterResult)result {
    [AWPurchaseKit queryCouponDetail:^(BOOL success, AWCouponModel * _Nullable model, AWError * _Nullable error) {
            if (success) {
                [self sendSuccess:result withData:model];
                return;
            }
            [self sendError:result withMsg:error.errorMessage];
    }];
}

/// 更新优惠券
- (void)updateCoupon:(NSDictionary*)arguments
         result:(FlutterResult)result {
    
    long taskId = [arguments[@"taskId"] longValue];
    
    if (!taskId) {
        [self sendError:result withMsg:@"non taskId"];
        return;
    }
    [AWPurchaseKit updateConponStateWithTaskId:taskId withCompletion:^(BOOL success, AWError * _Nullable error) {
            if (success) {
                [self sendSuccess:result withData:nil];
                return;
            }
            [self sendError:result withMsg:error.errorMessage];
    }];
    
}


- (void)sendSuccess:(FlutterResult)result
          withData:(__kindof NSObject *_Nullable) data {
    NSString *successStr = [self getResponseWithResult:YES withData:data withMsg:nil];
    result(successStr);
}

- (void)sendError:(FlutterResult)result
          withMsg:(NSString *) msg {
    NSString *errorStr = [self getResponseWithResult:NO withData:nil withMsg:msg];
    result(errorStr);
}

#pragma mark: - ios回调给flutter
- (void)purchases:(nonnull AWPurchaseInfo *)purchaseInfo {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //单项
    dic[@"inapps"] = [[AWPurchaseKit getPurchaseInfo] purchasedArray];
    //订阅
    dic[@"subs"] =  [[AWPurchaseKit getPurchaseInfo] getValidSubscriptions];
    dic[@"platform"] =  [NSNumber numberWithInt:1];
    
    [self.channel invokeMethod:@"onPurchased" arguments:[self getJSONStringFromDictionary:dic]];
}


#pragma mark: - 组装json数据
- (NSString *)getResponseWithResult:(Boolean)result
                               withData:(__kindof NSObject *_Nullable)data
                                withMsg:(NSString *)msg {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    dic[@"result"] = [NSNumber numberWithBool:result];
    if (data) {
        dic[@"data"] = data;
    }
    if (!msg) {
        msg = @"";
    }
    dic[@"msg"] = msg;
    return [self getJSONStringFromDictionary:dic];
}

- (NSString *)getJSONStringFromDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return @"";
    }
    NSString *string = [dictionary yy_modelToJSONString];

    return string;
}

@end
