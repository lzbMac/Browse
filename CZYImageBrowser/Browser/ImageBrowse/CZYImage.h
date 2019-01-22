//
//  CZYImage.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYFrameImage.h>
#import <YYImage/YYSpriteSheetImage.h>
#import <YYImage/YYImageCoder.h>
#import <YYImage/YYAnimatedImageView.h>
#elif __has_include(<YYWebImage/YYImage.h>)
#import <YYWebImage/YYFrameImage.h>
#import <YYWebImage/YYSpriteSheetImage.h>
#import <YYWebImage/YYImageCoder.h>
#import <YYWebImage/YYAnimatedImageView.h>
#else
#import "YYFrameImage.h"
#import "YYSpriteSheetImage.h"
#import "YYImageCoder.h"
#import "YYAnimatedImageView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CZYImage : UIImage<YYAnimatedImage>

+ (nullable CZYImage *)imageNamed:(NSString *)name; // no cache!
+ (nullable CZYImage *)imageWithContentsOfFile:(NSString *)path;
+ (nullable CZYImage *)imageWithData:(NSData *)data;
+ (nullable CZYImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;

/**
 如果图片以文件或数据的形式创建，该值会显示其数据类型
 */
@property (nonatomic, readonly) YYImageType animatedImageType;

/**
 如果图片以动图(multi-frame GIF/APNG/WebP)的形式创建，该属性会存储其数据原始类型
 */
@property (nullable, nonatomic, readonly) NSData *animatedImageData;

/**
 动图共占用内存大小，非动图默认为0
 */
@property (nonatomic, readonly) NSUInteger animatedImageMemorySize;

/**
 是否预加载所有图片尺寸
 */
@property (nonatomic) BOOL preloadAllAnimatedImageFrames;

@end

NS_ASSUME_NONNULL_END
