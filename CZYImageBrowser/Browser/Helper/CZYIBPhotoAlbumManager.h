//
//  CZYIBPhotoAlbumManager.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZYIBPhotoAlbumManager : NSObject
/**
 获取照片范文权限.
 */
+ (void)getPhotoAlbumAuthorizationSuccess:(nullable void(^)(void))success failed:(nullable void(^)(void))failed;

/**
 通过PHAsset异步获取AVAsset
 */
+ (void)getAVAssetWithPHAsset:(PHAsset *)phAsset success:(void(^)(AVAsset *asset))success failed:(void(^)(void))failed;

/**
 通过PHAsset异步获取图片数据
 */
+ (void)getImageDataWithPHAsset:(PHAsset *)phAsset success:(void(^)(NSData *data))success failed:(void(^)(void))failed;

+ (void)saveImageToAlbum:(UIImage *)image;

+ (void)saveDataToAlbum:(NSData *)data;

+ (void)saveVideoToAlbumWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
