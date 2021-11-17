//
//  NSObject+propertiesToDictionary.h
//  PurchaseSDK
//
//  Created by Yk Huang on 2021/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (propertiesToDictionary)

- (NSDictionary *)dictionaryFromModel;
@end

NS_ASSUME_NONNULL_END
