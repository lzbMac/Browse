//
//  CZYImageBrowseCellData.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYImageBrowseCellData.h"
#import "CZYImageBrowseCellData+Internal.h"
#import "CZYImageBrowseCell.h"
#import "CZYImageBrowser.h"
#import "CZYIBWebImageManager.h"
#import "CZYIBPhotoAlbumManager.h"
#import "CZYIBUtilities.h"
#import "CZYIBPhotoAlbumManager.h"
#import "CZYImageBrowserTipView.h"
#import "CZYIBCopywriter.h"

static CZYImageBrowseFillType _globalVerticalfillType = CZYImageBrowseFillTypeFullWidth;
static CZYImageBrowseFillType _globalHorizontalfillType = CZYImageBrowseFillTypeFullWidth;
static CGSize _globalMaxTextureSize = (CGSize){4096, 4096};
static CGFloat _globalZoomScaleSurplus = 1.5;
static BOOL _shouldDecodeAsynchronously = YES;

@interface CZYImageBrowseCellData () {
    __weak id _downloadToken;
}
@property (nonatomic, strong) CZYImage *image;
@property (nonatomic, assign) BOOL    isLoading;
@end

@implementation CZYImageBrowseCellData
#pragma mark - life cycle

- (void)dealloc {
    if (self->_downloadToken) {
        [CZYIBWebImageManager cancelTaskWithDownloadToken:self->_downloadToken];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initVars];
    }
    return self;
}

- (void)initVars {
    self->_maxZoomScale = 0;
    self->_verticalfillType = CZYImageBrowseFillTypeUnknown;
    self->_horizontalfillType = CZYImageBrowseFillTypeUnknown;
    self->_allowSaveToPhotoAlbum = YES;
    self->_allowShowSheetView = YES;
    
    self->_isCutting = NO;
    
    self->_isLoading = NO;
}

#pragma mark - <CZYImageBrowserCellDataProtocol>

- (Class)czy_classOfBrowserCell {
    return CZYImageBrowseCell.class;
}

- (id)czy_browserCellSourceObject {
    return self.sourceObject;
}

- (CGRect)czy_browserCurrentImageFrameWithImageSize:(CGSize)size {
    CZYImageBrowseFillType fillType = [self getFillTypeWithLayoutDirection:[CZYIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
    return [self.class getImageViewFrameWithContainerSize:[self.class getSizeOfCurrentLayoutDirection] imageSize:size fillType:fillType];
}

- (BOOL)czy_browserAllowShowSheetView {
    return self.allowShowSheetView;
}

- (BOOL)czy_browserAllowSaveToPhotoAlbum {
    return self.allowSaveToPhotoAlbum;
}

- (void)czy_browserSaveToPhotoAlbum {
    [CZYIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
        if ([self.image respondsToSelector:@selector(animatedImageData)] && self.image.animatedImageData) {
            [CZYIBPhotoAlbumManager saveDataToAlbum:self.image.animatedImageData];
        } else if (self.image) {
            [CZYIBPhotoAlbumManager saveImageToAlbum:self.image];
        } else if (self.url) {
            [CZYIBWebImageManager queryCacheOperationForKey:self.url completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
                if (data) {
                    CZYIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        self.image = [CZYImage imageWithData:data];
                        CZYIB_GET_QUEUE_MAIN_ASYNC(^{
                            [CZYIBPhotoAlbumManager saveImageToAlbum:self.image];
                        });
                    });
                } else {
                    [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].unableToSave];
                }
            }];
        } else {
            [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].unableToSave];
        }
    } failed:nil];
}

- (void)czy_preload {
    [self loadData];
}

#pragma mark - internal

- (void)loadData {
    if (self.isLoading) {
        CZYImageBrowseCellDataState tmpState = self.dataState;
        if (self.thumbImage) {
            self.dataState = CZYImageBrowseCellDataStateThumbImageReady;
        }
        self.dataState = tmpState;
        return;
    } else {
        self.isLoading = YES;
    }
    
    if (self.image) {
        [self loadLocalImage];
    } else if (self.imageBlock) {
        [self loadThumbImage];
        [self decodeLocalImage];
    } else if (self.url) {
        [self loadThumbImage];
        [self queryImageCache];
    } else if (self.phAsset) {
        [self loadThumbImage];
        [self loadImageFromPHAsset];
    } else {
        self.dataState = CZYImageBrowseCellDataStateInvalid;
        self.isLoading = NO;
    }
}

- (void)loadLocalImage {
    if (!self.image) return;
    if ([self needCompress]) {
        if (self.compressImage) {
            self.dataState = CZYImageBrowseCellDataStateCompressImageReady;
            self.isLoading = NO;
        } else {
            [self compressingImage];
        }
    } else {
        self.dataState = CZYImageBrowseCellDataStateImageReady;
        self.isLoading = NO;
    }
}

- (void)decodeLocalImage {
    if (!self.imageBlock) return;
    
    self.dataState = CZYImageBrowseCellDataStateIsDecoding;
    CZYIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.image = self.imageBlock();
        CZYIB_GET_QUEUE_MAIN_ASYNC(^{
            self.dataState = CZYImageBrowseCellDataStateDecodeComplete;
            if (self.image) {
                [self loadLocalImage];
            }
        });
    });
}

- (void)loadImageFromPHAsset {
    if (!self.phAsset) return;
    
    self.dataState = CZYImageBrowseCellDataStateIsLoadingPHAsset;
    
    static dispatch_queue_t assetQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetQueue = dispatch_queue_create("com.yangbo.czyimagebrowser.asset", DISPATCH_QUEUE_CONCURRENT);
    });
    
    dispatch_block_t block = ^{
        [CZYIBPhotoAlbumManager getImageDataWithPHAsset:self.phAsset success:^(NSData *imgData) {
            self.image = [CZYImage imageWithData:imgData];
            CZYIB_GET_QUEUE_MAIN_ASYNC(^{
                self.dataState = CZYImageBrowseCellDataStateLoadPHAssetSuccess;
                if (self.image) {
                    [self loadLocalImage];
                }
            });
        } failed:^{
            CZYIB_GET_QUEUE_MAIN_ASYNC(^{
                self.dataState = CZYImageBrowseCellDataStateLoadPHAssetFailed;
                self.isLoading = NO;
            });
        }];
    };
    
    CZYIB_GET_QUEUE_ASYNC(assetQueue, ^{
        block();
    });
}

- (void)queryImageCache {
    if (!self.url) return;
    
    self.dataState = CZYImageBrowseCellDataStateIsQueryingCache;
    [CZYIBWebImageManager queryCacheOperationForKey:self.url completed:^(id _Nullable image, NSData * _Nullable imagedata) {
        
        CZYIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (imagedata) {
                self.image = [CZYImage imageWithData:imagedata];
            }
            
            CZYIB_GET_QUEUE_MAIN_ASYNC(^{
                self.dataState = CZYImageBrowseCellDataStateQueryCacheComplete;
                
                if (self.image) {
                    [self loadLocalImage];
                } else {
                    [self downloadImage];
                }
            });
        });
    }];
}

- (void)downloadImage {
    if (!self.url) return;
    
    self.dataState = CZYImageBrowseCellDataStateIsDownloading;
    self->_downloadToken = [CZYIBWebImageManager downloadImageWithURL:self.url progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        CGFloat value = receivedSize * 1.0 / expectedSize ?: 0;
        self->_downloadProgress = value;
        
        CZYIB_GET_QUEUE_MAIN_ASYNC(^{
            self.dataState = CZYImageBrowseCellDataStateDownloadProcess;
        })
    } success:^(UIImage * _Nullable image, NSData * _Nullable nsData, BOOL finished) {
        if (!finished) return;
        
        CZYIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.image = [CZYImage imageWithData:nsData];
            
            CZYIB_GET_QUEUE_MAIN_ASYNC(^{
                [CZYIBWebImageManager storeImage:self.image imageData:nsData forKey:self.url toDisk:YES];
                
                self.dataState = CZYImageBrowseCellDataStateDownloadSuccess;
                if (self.image) {
                    [self loadLocalImage];
                }
            });
        });
        
    } failed:^(NSError * _Nullable error, BOOL finished) {
        if (!finished) return;
        self.dataState = CZYImageBrowseCellDataStateDownloadFailed;
        self.isLoading = NO;
    }];
}

- (void)loadThumbImage {
    if (self.thumbImage) {
        self.dataState = CZYImageBrowseCellDataStateThumbImageReady;
    } else if (self.sourceObject && [self.sourceObject isKindOfClass:UIImageView.class] && ((UIImageView *)self.sourceObject).image) {
        self.thumbImage = ((UIImageView *)self.sourceObject).image;
        self.dataState = CZYImageBrowseCellDataStateThumbImageReady;
    } else if (self.thumbUrl) {
        [CZYIBWebImageManager queryCacheOperationForKey:self.thumbUrl completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
            if (image) {
                self.thumbImage = image;
            } else if (data) {
                self.thumbImage = [UIImage imageWithData:data];
            }
            
            // If the target image is ready, ignore the thumb image.
            if (self.dataState != CZYImageBrowseCellDataStateCompressImageReady && self.dataState != CZYImageBrowseCellDataStateImageReady) {
                self.dataState = CZYImageBrowseCellDataStateThumbImageReady;
            }
        }];
    }
}

- (void)compressingImage {
    if (!self.image) return;
    
    self.dataState = CZYImageBrowseCellDataStateIsCompressingImage;
    CGSize size = [self getSizeOfCompressing];
    
    CZYIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContext(size);
        [self.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        self->_compressImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CZYIB_GET_QUEUE_MAIN_ASYNC(^{
            self.dataState = CZYImageBrowseCellDataStateCompressImageComplete;
            [self loadLocalImage];
        })
    })
}

- (void)cuttingImageToRect:(CGRect)rect complete:(void(^)(UIImage *image))complete {
    if (!self.image) return;
    if (self->_isCutting) return;
    
    self->_isCutting = YES;
    CZYIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef cgImage = CGImageCreateWithImageInRect(self.image.CGImage, rect);
        UIImage *resultImg = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        CZYIB_GET_QUEUE_MAIN_ASYNC(^{
            self->_isCutting = NO;
            if (complete) complete(resultImg);
        })
    })
}

- (CZYImageBrowseFillType)getFillTypeWithLayoutDirection:(CZYImageBrowserLayoutDirection)layoutDirection {
    CZYImageBrowseFillType fillType;
    if (layoutDirection == CZYImageBrowserLayoutDirectionHorizontal) {
        fillType = self.horizontalfillType == CZYImageBrowseFillTypeUnknown ? CZYImageBrowseCellData.globalHorizontalfillType : self.horizontalfillType;
    } else {
        fillType = self.verticalfillType == CZYImageBrowseFillTypeUnknown ? CZYImageBrowseCellData.globalVerticalfillType : self.verticalfillType;
    }
    return fillType == CZYImageBrowseFillTypeUnknown ? CZYImageBrowseFillTypeFullWidth : fillType;
}

- (BOOL)needCompress {
    if (!self.image) return NO;
    return CZYImageBrowseCellData.globalMaxTextureSize.width * CZYImageBrowseCellData.globalMaxTextureSize.height < self.image.size.width * self.image.scale * self.image.size.height * self.image.scale;
}

+ (CGFloat)getMaximumZoomScaleWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(CZYImageBrowseFillType)fillType {
    if (containerSize.width <= 0 || containerSize.height <= 0) return 0;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale <= 0) return 0;
    CGFloat widthScale = imageSize.width / scale / containerSize.width,
    heightScale = imageSize.height / scale / containerSize.height,
    maxScale = 1;
    switch (fillType) {
        case CZYImageBrowseFillTypeFullWidth:
            maxScale = widthScale;
            break;
        case CZYImageBrowseFillTypeCompletely:
            maxScale = MAX(widthScale, heightScale);
            break;
        case CZYImageBrowseFillTypeUnknown: break;
    }
    return MAX(maxScale, 1) * CZYImageBrowseCellData.globalZoomScaleSurplus;
}

+ (CGRect)getImageViewFrameWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(CZYImageBrowseFillType)fillType {
    if (containerSize.width <= 0 || containerSize.height <= 0 || imageSize.width <= 0 || imageSize.height <= 0) return CGRectZero;
    CGFloat x = 0, y = 0, width = 0, height = 0;
    switch (fillType) {
        case CZYImageBrowseFillTypeFullWidth: {
            x = 0;
            width = containerSize.width;
            height = containerSize.width * (imageSize.height / imageSize.width);
            if (imageSize.width / imageSize.height >= containerSize.width / containerSize.height)
                y = (containerSize.height - height) / 2.0;
            else
                y = 0;
        }
            break;
        case CZYImageBrowseFillTypeCompletely: {
            if (imageSize.width / imageSize.height >= containerSize.width / containerSize.height) {
                width = containerSize.width;
                height = containerSize.width * (imageSize.height / imageSize.width);
                x = 0;
                y = (containerSize.height - height) / 2.0;
            } else {
                height = containerSize.height;
                width = containerSize.height * (imageSize.width / imageSize.height);
                x = (containerSize.width - width) / 2.0;
                y = 0;
            }
        }
            break;
        case CZYImageBrowseFillTypeUnknown: break;
    }
    return CGRectMake(x, y, width, height);
}

+ (CGSize)getContentSizeWithContainerSize:(CGSize)containerSize imageViewFrame:(CGRect)imageViewFrame {
    return CGSizeMake(MAX(containerSize.width, imageViewFrame.size.width), MAX(containerSize.height, imageViewFrame.size.height));
}

#pragma mark - private

+ (CGSize)getSizeOfCurrentLayoutDirection {
    return [CZYIBLayoutDirectionManager getLayoutDirectionByStatusBar] == CZYImageBrowserLayoutDirectionHorizontal ? CGSizeMake(CZYIMAGEBROWSER_HEIGHT, CZYIMAGEBROWSER_WIDTH) : CGSizeMake(CZYIMAGEBROWSER_WIDTH, CZYIMAGEBROWSER_HEIGHT);
}

- (CGSize)getSizeOfCompressing {
    CZYImageBrowseFillType fillType = [self getFillTypeWithLayoutDirection:[CZYIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
    CGSize imageViewsize = [self.class getImageViewFrameWithContainerSize:[self.class getSizeOfCurrentLayoutDirection] imageSize:self.image.size fillType:fillType].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(floor(imageViewsize.width * scale), floor(imageViewsize.height * scale));
    return size;
}

#pragma mark - setter

- (void)setUrl:(NSURL *)url {
    _url = [url isKindOfClass:NSString.class] ? [NSURL URLWithString:(NSString *)url] : url;
}

+ (void)setGlobalVerticalfillType:(CZYImageBrowseFillType)globalVerticalfillType {
    _globalVerticalfillType = globalVerticalfillType;
}

+ (void)setGlobalHorizontalfillType:(CZYImageBrowseFillType)globalHorizontalfillType {
    _globalHorizontalfillType = globalHorizontalfillType;
}

+ (void)setGlobalMaxTextureSize:(CGSize)globalMaxTextureSize {
    _globalMaxTextureSize = globalMaxTextureSize;
}

+ (void)setGlobalZoomScaleSurplus:(CGFloat)globalZoomScaleSurplus {
    _globalZoomScaleSurplus = globalZoomScaleSurplus;
}

+ (void)setShouldDecodeAsynchronously:(BOOL)shouldDecodeAsynchronously {
    _shouldDecodeAsynchronously = shouldDecodeAsynchronously;
}

#pragma mark - getter

+ (CZYImageBrowseFillType)globalVerticalfillType {
    return _globalVerticalfillType;
}

+ (CZYImageBrowseFillType)globalHorizontalfillType {
    return _globalHorizontalfillType;
}

+ (CGSize)globalMaxTextureSize {
    return _globalMaxTextureSize;
}

+ (CGFloat)globalZoomScaleSurplus {
    return _globalZoomScaleSurplus;
}

+ (BOOL)shouldDecodeAsynchronously {
    return _shouldDecodeAsynchronously;
}
@end
