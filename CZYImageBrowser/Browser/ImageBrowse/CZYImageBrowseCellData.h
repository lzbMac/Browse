//
//  CZYImageBrowseCellData.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "CZYImageBrowserCellDataProtocol.h"
#import "CZYImage.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, CZYImageBrowseFillType) {
    CZYImageBrowseFillTypeUnknown,
    
    // 宽度与屏幕同宽，高度自适应.
    CZYImageBrowseFillTypeFullWidth,
    // 图片最大展示但会确保完整.
    CZYImageBrowseFillTypeCompletely
};

typedef __kindof UIImage * _Nullable (^CZYIBLocalImageBlock)(void);

@interface CZYImageBrowseCellData : NSObject

/**
 获取本地图片，建议使用'CZYImage','CZYImage' 与 'UIImage'一样，但支持GIF, WebP 和 APNG格式
 */
@property (nonatomic, copy)CZYIBLocalImageBlock imageBlock;

/**
 网络图片地址
 */
@property (nonatomic, strong, nullable) NSURL *url;
/**
 系统相册图片
 */
@property (nonatomic, strong, nullable) PHAsset *phAsset;

/**
 图片浏览时动画起点视图，一般为'UIImageView'，也可以是'UIView' 或者 'CALayer'
 */
@property (nonatomic, weak, nullable) id sourceObject;

/**
 预览图，一般为低质量图片.
 如果 'sourceObject' 是 'UIImageView', 'thumbImage'会被自动设置 .
 */
@property (nonatomic, strong, nullable) UIImage *thumbImage;

/**
 预览图片地址，当内存不存在此图片缓存时该设置失效
 */
@property (nonatomic, strong, nullable) NSURL *thumbUrl;

/**
 最终图片
 */
@property (nonatomic, strong, readonly, nullable) CZYImage *image;

/**
 最大缩放比例，必须大于1
 */
@property (nonatomic, assign) CGFloat maxZoomScale;

/**
 当缩放比例自动计算时，计算结果会乘以当前属性作为最终结果。 默认值为 1.5.
 */
@property (nonatomic, class) CGFloat globalZoomScaleSurplus;

/**
 最大值默认为 '(CGSize){4096, 4096}'.
 当图片超过其最大尺寸会被异步压缩与裁剪.
 最好在设置其他属性前设置该属性.
 */
@property (nonatomic, class) CGSize globalMaxTextureSize;

/** 默认为 'CZYImageBrowseFillTypeFullWidth'. */
@property (nonatomic, class) CZYImageBrowseFillType globalVerticalfillType;

/** 默认为 'CZYImageBrowseFillTypeFullWidth'. */
@property (nonatomic, class) CZYImageBrowseFillType globalHorizontalfillType;

/**
 设置该属性后，会忽略全局设置
 */
@property (nonatomic, assign) CZYImageBrowseFillType verticalfillType;

/**
 设置该属性后，会忽略全局设置
 */
@property (nonatomic, assign) CZYImageBrowseFillType horizontalfillType;

/** 默认为 YES. */
@property (nonatomic, assign) BOOL allowSaveToPhotoAlbum;

/** 默认为 YES. */
@property (nonatomic, assign) BOOL allowShowSheetView;

/** You can set any data. */
@property (nonatomic, strong, nullable) id extraData;

/** 默认为 YES.
 如果图片的解码导致卡顿，可设置该值为YES，当异步解码时会花费更所时间
 */
@property (nonatomic, class) BOOL shouldDecodeAsynchronously;
@end

NS_ASSUME_NONNULL_END
