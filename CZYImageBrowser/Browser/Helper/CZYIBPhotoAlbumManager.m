//
//  CZYIBPhotoAlbumManager.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYIBPhotoAlbumManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CZYIBCopywriter.h"
#import "CZYImageBrowserTipView.h"
#import "CZYIBUtilities.h"

@implementation CZYIBPhotoAlbumManager
+ (void)getPhotoAlbumAuthorizationSuccess:(void (^)(void))success failed:(void (^)(void))failed {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusDenied:
            [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].getPhotoAlbumAuthorizationFailed];
            if (failed) failed();
            break;
        case PHAuthorizationStatusRestricted:
            [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].getPhotoAlbumAuthorizationFailed];
            if (failed) failed();
            break;
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                CZYIB_GET_QUEUE_MAIN_ASYNC(^{
                    if (status == PHAuthorizationStatusAuthorized) {
                        if (success) success();
                    } else {
                        if (failed) failed();
                    }
                })
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
            if (success) success();
            break;
    }
}

+ (void)getAVAssetWithPHAsset:(PHAsset *)phAsset success:(void (^)(AVAsset * _Nonnull))success failed:(void (^)(void))failed {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        CZYIB_GET_QUEUE_MAIN_ASYNC(^{
            if (asset) {
                if (success) success(asset);
            } else {
                if (failed) failed();
            }
        })
    }];
}

+ (void)getImageDataWithPHAsset:(PHAsset *)phAsset success:(void(^)(NSData *))success failed:(void(^)(void))failed {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    option.synchronous = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL complete = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (complete && imageData) {
            if (success) success(imageData);
        } else {
            if (failed) failed();
        }
    }];
}

+ (void)saveDataToAlbum:(NSData *)data {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumFailed];
        } else {
            [[UIApplication sharedApplication].keyWindow czy_showHookTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumSuccess];
        }
    }];
#pragma clang diagnostic pop
    
}

+ (void)saveImageToAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), NULL);
}

+ (void)completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)context {
    if (error) {
        [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumFailed];
    } else {
        [[UIApplication sharedApplication].keyWindow czy_showHookTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumSuccess];
    }
}

+ (void)saveVideoToAlbumWithPath:(NSString *)path {
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    } else {
        [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].unableToSave];
    }
}

+ (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumFailed];
    } else {
        [[UIApplication sharedApplication].keyWindow czy_showHookTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumSuccess];
    }
}

@end
