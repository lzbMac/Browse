//
//  CZYVideoBrowseCellData.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "CZYImageBrowserCellDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CZYVideoBrowseCellData : NSObject <CZYImageBrowserCellDataProtocol>

/**
 url地址
 */
@property (nonatomic, strong, nullable) NSURL *url;

/**
本地asset
 */
@property (nonatomic, strong, nullable) PHAsset *phAsset;

/** 使用 'AVURLAsset'. */
@property (nonatomic, strong, nullable) AVAsset *avAsset;

/**
 图片浏览时动画起点视图，一般为'UIImageView'，也可以是'UIView' 或者 'CALayer'
 */
@property (nonatomic, weak, nullable) id sourceObject;

/**
 预览图，没有将加载视频第一帧图片.
 */
@property (nonatomic, strong, nullable) UIImage *firstFrame;

/**
 自动播放次数，挡自动播时放卡顿，可以禁止使用自动播放，默认为0
 */
@property (nonatomic, assign) NSUInteger autoPlayCount;

/**
 重复播放次数，默认为0
 */
@property (nonatomic, assign) NSUInteger repeatPlayCount;

/**
 默认为 YES.
 */
@property (nonatomic, assign) BOOL allowSaveToPhotoAlbum;

/**
 默认为 YES.
 */
@property (nonatomic, assign) BOOL allowShowSheetView;

/** You can set any data. */
@property (nonatomic, strong, nullable) id extraData;

@end

NS_ASSUME_NONNULL_END
