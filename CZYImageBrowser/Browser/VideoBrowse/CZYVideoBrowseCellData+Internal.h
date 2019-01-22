//
//  CZYVideoBrowseCellData+Internal.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYVideoBrowseCellData.h"

typedef NS_ENUM(NSInteger, CZYVideoBrowseCellDataState) {
    CZYVideoBrowseCellDataStateInvalid,
    CZYVideoBrowseCellDataStateFirstFrameReady,
    
    CZYVideoBrowseCellDataStateIsLoadingFirstFrame,
    CZYVideoBrowseCellDataStateLoadFirstFrameSuccess,
    CZYVideoBrowseCellDataStateLoadFirstFrameFailed,
    
    CZYVideoBrowseCellDataStateIsLoadingPHAsset,
    CZYVideoBrowseCellDataStateLoadPHAssetSuccess,
    CZYVideoBrowseCellDataStateLoadPHAssetFailed
};

typedef NS_ENUM(NSInteger, CZYVideoBrowseCellDataDownloadState) {
    CZYVideoBrowseCellDataDownloadStateNone,
    CZYVideoBrowseCellDataDownloadStateIsDownloading,
    CZYVideoBrowseCellDataDownloadStateComplete
};

@interface CZYVideoBrowseCellData ()

@property (nonatomic, assign) CZYVideoBrowseCellDataState dataState;

@property (nonatomic, assign) CZYVideoBrowseCellDataDownloadState dataDownloadState;

@property (nonatomic, assign) CGFloat downloadingVideoProgress;

- (void)loadData;

+ (CGRect)getImageViewFrameWithImageSize:(CGSize)size;

@end
