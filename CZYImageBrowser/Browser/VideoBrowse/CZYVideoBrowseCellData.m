//
//  CZYVideoBrowseCellData.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYVideoBrowseCellData.h"
#import "CZYVideoBrowseCell.h"
#import "CZYImageBrowserCellDataProtocol.h"
#import "CZYIBPhotoAlbumManager.h"
#import "CZYVideoBrowseCellData+Internal.h"
#import "CZYIBUtilities.h"
#import "CZYIBLayoutDirectionManager.h"
#import "CZYImageBrowserTipView.h"
#import "CZYImageBrowserProgressView.h"
#import "CZYIBCopywriter.h"

@interface CZYVideoBrowseCellData () <NSURLSessionDelegate> {
    NSURLSessionDownloadTask *_downloadTask;
}
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation CZYVideoBrowseCellData

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initVars];
    }
    return self;
}

- (void)initVars {
    self->_autoPlayCount = 0;
    self->_allowSaveToPhotoAlbum = YES;
    self->_allowShowSheetView = YES;
    self->_dataState = CZYVideoBrowseCellDataStateInvalid;
    self->_dataDownloadState = CZYVideoBrowseCellDataDownloadStateNone;
    self->_isLoading = NO;
}

#pragma mark - <CZYImageBrowserCellDataProtocol>

- (Class)czy_classOfBrowserCell {
    return CZYVideoBrowseCell.class;
}

- (id)czy_browserCellSourceObject {
    return self.sourceObject;
}

- (CGRect)czy_browserCurrentImageFrameWithImageSize:(CGSize)size {
    return [self.class getImageViewFrameWithImageSize:size];
}

- (BOOL)czy_browserAllowShowSheetView {
    return self.allowShowSheetView;
}

- (BOOL)czy_browserAllowSaveToPhotoAlbum {
    return self.allowSaveToPhotoAlbum;
}

- (void)czy_browserSaveToPhotoAlbum {
    if (self.avAsset && [self.avAsset isKindOfClass:AVURLAsset.class]) {
        AVURLAsset *asset = (AVURLAsset *)self.avAsset;
        NSURL *url = asset.URL;
        if ([url.scheme isEqualToString:@"file"]) {
            [CZYIBPhotoAlbumManager saveVideoToAlbumWithPath:url.path];
        } else if ([url.scheme containsString:@"http"]) {
            [self downloadWithUrl:url];
        } else {
            [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].videoIsInvalid];
        }
    } else {
        [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].unableToSave];
    }
}

- (void)czy_preload {
    [self loadData];
}

#pragma mark - internal

- (void)loadData {
    if (self.isLoading) {
        self.dataState = self.dataState;
        return;
    } else {
        self.isLoading = YES;
    }
    
    if (self.avAsset) {
        [self loadFirstFrameOfVideo];
    } else if (self.phAsset) {
        [self loadLocalFirstFrameOfVideo];
        [self loadAVAssetFromPHAsset];
    } else {
        self.dataState = CZYVideoBrowseCellDataStateInvalid;
        self.isLoading = NO;
    }
}

- (void)loadAVAssetFromPHAsset {
    if (!self.phAsset) return;
    
    self.dataState = CZYVideoBrowseCellDataStateIsLoadingPHAsset;
    [CZYIBPhotoAlbumManager getAVAssetWithPHAsset:self.phAsset success:^(AVAsset *asset) {
        self.avAsset = asset;

        self.dataState = CZYVideoBrowseCellDataStateLoadPHAssetSuccess;
        [self loadFirstFrameOfVideo];
    } failed:^{
        self.dataState = CZYVideoBrowseCellDataStateLoadPHAssetFailed;
        self.isLoading = NO;
    }];
}

- (BOOL)loadLocalFirstFrameOfVideo {
    if (self.firstFrame) {
        self.dataState = CZYVideoBrowseCellDataStateFirstFrameReady;
        self.isLoading = NO;
    } else if (self.sourceObject && [self.sourceObject isKindOfClass:UIImageView.class] && ((UIImageView *)self.sourceObject).image) {
        self.firstFrame = ((UIImageView *)self.sourceObject).image;
        self.dataState = CZYVideoBrowseCellDataStateFirstFrameReady;
        self.isLoading = NO;
    } else {
        return NO;
    }
    return YES;
}

- (void)loadFirstFrameOfVideo {
    if (!self.avAsset) return;
    if ([self loadLocalFirstFrameOfVideo]) return;
    
    self.dataState = CZYVideoBrowseCellDataStateIsLoadingFirstFrame;
    CGSize size = [self.class getPixelSizeOfCurrentLayoutDirection];
    CZYIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.avAsset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = size;
        NSError *error = nil;
        CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:NULL error:&error];
        UIImage *result = cgImage ? [UIImage imageWithCGImage:cgImage] : nil;
        CZYIB_GET_QUEUE_MAIN_ASYNC(^{
            if (error || !result) {
                self.dataState = CZYVideoBrowseCellDataStateLoadFirstFrameFailed;
                self.isLoading = NO;
            } else {
                self.firstFrame = result;
                self.dataState = CZYVideoBrowseCellDataStateLoadFirstFrameSuccess;
                self.dataState = CZYVideoBrowseCellDataStateFirstFrameReady;
                self.isLoading = NO;
            }
        })
    })
}

+ (CGRect)getImageViewFrameWithImageSize:(CGSize)size {
    CGSize cSize = [self.class getSizeOfCurrentLayoutDirection];
    if (cSize.width <= 0 || cSize.height <= 0 || size.width <= 0 || size.height <= 0) return CGRectZero;
    CGFloat x = 0, y = 0, width = 0, height = 0;
    if (size.width / size.height >= cSize.width / cSize.height) {
        width = cSize.width;
        height = cSize.width * (size.height / size.width);
        x = 0;
        y = (cSize.height - height) / 2.0;
    } else {
        height = cSize.height;
        width = cSize.height * (size.width / size.height);
        x = (cSize.width - width) / 2.0;
        y = 0;
    }
    return CGRectMake(x, y, width, height);
}

#pragma mark - private

+ (CGSize)getPixelSizeOfCurrentLayoutDirection {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = [self getSizeOfCurrentLayoutDirection];
    return CGSizeMake(size.width * scale, size.height * scale);
}

+ (CGSize)getSizeOfCurrentLayoutDirection {
    CGSize size = [CZYIBLayoutDirectionManager getLayoutDirectionByStatusBar] == CZYImageBrowserLayoutDirectionHorizontal ? CGSizeMake(CZYIMAGEBROWSER_HEIGHT, CZYIMAGEBROWSER_WIDTH) : CGSizeMake(CZYIMAGEBROWSER_WIDTH, CZYIMAGEBROWSER_HEIGHT);
    return size;
}

- (void)downloadWithUrl:(NSURL *)url {
    if (self.dataDownloadState == CZYVideoBrowseCellDataDownloadStateIsDownloading) {
        self.dataDownloadState = CZYVideoBrowseCellDataDownloadStateIsDownloading;
        return;
    }
    self.downloadingVideoProgress = 0;
    self.dataDownloadState = CZYVideoBrowseCellDataDownloadStateIsDownloading;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self->_downloadTask = [session downloadTaskWithURL:url];
    [self->_downloadTask resume];
}

#pragma mark - <NSURLSessionDelegate>

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    self.downloadingVideoProgress = progress;
    self.dataDownloadState = CZYVideoBrowseCellDataDownloadStateIsDownloading;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    self.dataDownloadState = CZYVideoBrowseCellDataDownloadStateComplete;
    if (error) {
        [[UIApplication sharedApplication].keyWindow czy_showForkTipView:@"下载失败"];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)) {
        UISaveVideoAtPathToSavedPhotosAlbum(file, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    } else {
        self.dataDownloadState = CZYVideoBrowseCellDataDownloadStateComplete;
        [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumFailed];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    self.dataDownloadState = CZYVideoBrowseCellDataDownloadStateComplete;
    if (error) {
        [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumFailed];
    } else {
        [[UIApplication sharedApplication].keyWindow czy_showHookTipView:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbumSuccess];
    }
}

#pragma mark - setter

- (void)setUrl:(NSURL *)url {
    _url = [url isKindOfClass:NSString.class] ? [NSURL URLWithString:(NSString *)url] : url;
    self.avAsset = [AVURLAsset URLAssetWithURL:self->_url options:nil];
}

@end
