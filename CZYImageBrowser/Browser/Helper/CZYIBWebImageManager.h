//
//  CZYIBWebImageManager.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CZYIBWebImageManagerProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);
typedef void(^CZYIBWebImageManagerSuccessBlock)(UIImage * _Nullable image, NSData * _Nullable data, BOOL finished);
typedef void(^CZYIBWebImageManagerFailedBlock)(NSError * _Nullable error, BOOL finished);
typedef void(^CZYIBWebImageManagerCacheQueryCompletedBlock)(UIImage * _Nullable image, NSData * _Nullable data);

@interface CZYIBWebImageManager : NSObject

+ (void)storeOutsideConfiguration;

+ (void)restoreOutsideConfiguration;

+ (id)downloadImageWithURL:(NSURL *)url progress:(CZYIBWebImageManagerProgressBlock)progress success:(CZYIBWebImageManagerSuccessBlock)success failed:(CZYIBWebImageManagerFailedBlock)failed;

+ (void)cancelTaskWithDownloadToken:(id)token;

+ (void)storeImage:(nullable UIImage *)image imageData:(nullable NSData *)data forKey:(NSURL *)key toDisk:(BOOL)toDisk;

+ (void)queryCacheOperationForKey:(NSURL *)key completed:(CZYIBWebImageManagerCacheQueryCompletedBlock)completed;

@end

NS_ASSUME_NONNULL_END
