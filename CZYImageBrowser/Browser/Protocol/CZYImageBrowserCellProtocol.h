//
//  CZYImageBrowserCellProtocol.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZYImageBrowserCellDataProtocol.h"
#import "CZYIBGestureInteractionProfile.h"
#import "CZYIBLayoutDirectionManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CZYImageBrowserCellProtocol <NSObject>
@required

- (void)czy_initializeBrowserCellWithData:(id<CZYImageBrowserCellDataProtocol>)data layoutDirection:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

@optional

- (void)czy_browserLayoutDirectionChanged:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

@property (nonatomic, copy) void(^czy_browserDismissBlock)(void);

@property (nonatomic, copy) void(^czy_browserToolBarHiddenBlock)(BOOL hidden);

@property (nonatomic, copy) void(^czy_browserScrollEnabledBlock)(BOOL enabled);

@property (nonatomic, copy) void(^czy_browserChangeAlphaBlock)(CGFloat alpha, CGFloat duration);

- (void)czy_browserPageIndexChanged:(NSUInteger)pageIndex ownIndex:(NSUInteger)ownIndex;

- (void)czy_browserBodyIsInTheCenter:(BOOL)isIn;

- (void)czy_browserInitializeFirst:(BOOL)isFirst;

- (void)czy_browserStatusBarOrientationBefore:(UIInterfaceOrientation)orientation;

- (__kindof UIView *)czy_browserCurrentForegroundView;

- (void)czy_browserSetGestureInteractionProfile:(CZYIBGestureInteractionProfile *)giProfile;

@end

NS_ASSUME_NONNULL_END
