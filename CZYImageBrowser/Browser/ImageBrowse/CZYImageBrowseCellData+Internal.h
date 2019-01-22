//
//  CZYImageBrowseCellData+Internal.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYImageBrowseCellData.h"
#import "CZYIBLayoutDirectionManager.h"

typedef NS_ENUM(NSInteger, CZYImageBrowseCellDataState) {
    CZYImageBrowseCellDataStateInvalid,
    CZYImageBrowseCellDataStateImageReady,
    CZYImageBrowseCellDataStateCompressImageReady,
    
    CZYImageBrowseCellDataStateThumbImageReady,
    
    CZYImageBrowseCellDataStateIsDecoding,
    CZYImageBrowseCellDataStateDecodeComplete,
    
    CZYImageBrowseCellDataStateIsCompressingImage,
    CZYImageBrowseCellDataStateCompressImageComplete,
    
    CZYImageBrowseCellDataStateIsLoadingPHAsset,
    CZYImageBrowseCellDataStateLoadPHAssetSuccess,
    CZYImageBrowseCellDataStateLoadPHAssetFailed,
    
    CZYImageBrowseCellDataStateIsQueryingCache,
    CZYImageBrowseCellDataStateQueryCacheComplete,
    
    CZYImageBrowseCellDataStateIsDownloading,
    CZYImageBrowseCellDataStateDownloadProcess,
    CZYImageBrowseCellDataStateDownloadSuccess,
    CZYImageBrowseCellDataStateDownloadFailed,
};

@interface CZYImageBrowseCellData ()

@property (nonatomic, assign) CZYImageBrowseCellDataState dataState;

@property (nonatomic, strong) UIImage *compressImage;
@property (nonatomic, assign) CGFloat downloadProgress;
@property (nonatomic, assign) BOOL    isCutting;

- (void)loadData;

- (void)cuttingImageToRect:(CGRect)rect complete:(void(^)(UIImage *image))complete;

- (BOOL)needCompress;

- (CZYImageBrowseFillType)getFillTypeWithLayoutDirection:(CZYImageBrowserLayoutDirection)layoutDirection;

+ (CGFloat)getMaximumZoomScaleWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(CZYImageBrowseFillType)fillType;

+ (CGRect)getImageViewFrameWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(CZYImageBrowseFillType)fillType;

+ (CGSize)getContentSizeWithContainerSize:(CGSize)containerSize imageViewFrame:(CGRect)imageViewFrame;

@end
