//
//  CZYImageBrowserView.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZYImageBrowserDataSource.h"
#import "CZYIBLayoutDirectionManager.h"
#import "CZYIBUtilities.h"
#import "CZYIBGestureInteractionProfile.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CZYImageBrowserViewDelegate <NSObject>

@required

- (void)czy_imageBrowserViewDismiss:(CZYImageBrowserView *)browserView;

- (void)czy_imageBrowserView:(CZYImageBrowserView *)browserView changeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration;

- (void)czy_imageBrowserView:(CZYImageBrowserView *)browserView pageIndexChanged:(NSUInteger)index;

- (void)czy_imageBrowserView:(CZYImageBrowserView *)browserView hideTooBar:(BOOL)hidden;

@end

@interface CZYImageBrowserView : UICollectionView


@property (nonatomic, weak) id<CZYImageBrowserDataSource> czy_dataSource;

@property (nonatomic, weak) UIViewController<CZYImageBrowserViewDelegate> *czy_delegate;

@property (nonatomic, assign, readonly) NSUInteger currentIndex;

- (id<CZYImageBrowserCellDataProtocol>)currentData;

- (id<CZYImageBrowserCellDataProtocol>)dataAtIndex:(NSUInteger)index;

- (void)preloadWithCurrentIndex:(NSInteger)index;

- (void)updateLayoutWithDirection:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

- (void)scrollToPageWithIndex:(NSInteger)index;

- (void)czy_reloadData;

@property (nonatomic, strong) CZYIBGestureInteractionProfile *giProfile;

@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientationBefore;

@property (nonatomic, assign) NSUInteger cacheCountLimit;

@property (nonatomic, assign) BOOL shouldPreload;


@end

NS_ASSUME_NONNULL_END
