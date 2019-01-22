//
//  CZYImageBrowserDelegate.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CZYImageBrowser;

@protocol CZYImageBrowserDelegate <NSObject>

@optional

- (void)czy_imageBrowser:(CZYImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<CZYImageBrowserCellDataProtocol>)data;

- (void)czy_imageBrowser:(CZYImageBrowser *)imageBrowser respondsToLongPress:(UILongPressGestureRecognizer *)longPress;

- (void)czy_imageBrowser:(CZYImageBrowser *)imageBrowser transitionAnimationEndedWithIsEnter:(BOOL)isEnter;

@end

NS_ASSUME_NONNULL_END
