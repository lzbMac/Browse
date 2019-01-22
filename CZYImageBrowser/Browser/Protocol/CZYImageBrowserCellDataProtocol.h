//
//  CZYImageBrowserCellDataProtocol.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CZYImageBrowserCellDataProtocol <NSObject>

@required

- (Class)czy_classOfBrowserCell;

@optional

- (id)czy_browserCellSourceObject;

- (BOOL)czy_browserAllowSaveToPhotoAlbum;
- (void)czy_browserSaveToPhotoAlbum;

- (BOOL)czy_browserAllowShowSheetView;

- (CGRect)czy_browserCurrentImageFrameWithImageSize:(CGSize)size;

- (void)czy_preload;

@end

NS_ASSUME_NONNULL_END
